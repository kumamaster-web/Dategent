# frozen_string_literal: true

# Uses RubyLLM to evaluate compatibility between two users via a single
# LLM call. Creates a Match record and either advances to NegotiationJob
# (score >= threshold) or declines.
#
# Pipeline: MatchmakerJob → ScreeningJob → NegotiationJob (if passed)
class ScreeningJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  SCREENING_THRESHOLD = 60.0

  def perform(initiator_user_id, candidate_user_id)
    initiator = User.includes(:user_preference, :agent).find(initiator_user_id)
    candidate = User.includes(:user_preference, :agent).find(candidate_user_id)

    init_ctx = AgentContextBuilder.new(initiator)
    cand_ctx = AgentContextBuilder.new(candidate)

    # Create or find the match in screening status
    match = Match.find_or_create_by!(
      initiator_agent: initiator.agent,
      receiver_agent: candidate.agent
    ) do |m|
      m.status = "screening"
      m.compatibility_score = 0.0
    end

    # Skip if already past screening (idempotency guard)
    return unless match.screening?

    # RubyLLM persisted Chat — system prompt + single evaluation call
    chat = Chat.create!
    chat.with_instructions(screening_system_prompt)
    response = chat.ask(screening_prompt(init_ctx, cand_ctx))

    result = parse_screening_result(response.content)

    new_status = result[:score] >= SCREENING_THRESHOLD ? "evaluating" : "declined"

    match.update!(
      compatibility_score: result[:score],
      compatibility_summary: result[:summary],
      chat_transcript: result[:reasoning],
      status: new_status
    )

    # Persist stage transcript for history
    match.record_transcript!("screening", result[:reasoning])

    # Advance to agent-to-agent negotiation if passed screening
    NegotiationJob.perform_later(match.id) if match.evaluating?

    Rails.logger.info "[ScreeningJob] #{initiator.first_name} ↔ #{candidate.first_name}: " \
                      "score=#{result[:score]}, status=#{new_status}"
  end

  private

  def screening_system_prompt
    <<~PROMPT
      You are an impartial dating compatibility screener. You evaluate two anonymized profiles
      and determine if they should be introduced for a potential date.

      Respond ONLY in this exact JSON format:
      {
        "score": <number 0-100>,
        "summary": "<2-3 sentence compatibility summary>",
        "reasoning": "<detailed bullet-point analysis>",
        "dealbreakers": ["<list any dealbreakers found>"]
      }

      Scoring guide:
      - 80-100: Excellent match, strong alignment on values and lifestyle
      - 60-79: Good match, some differences but worth exploring
      - 40-59: Marginal, significant gaps in key areas
      - 0-39: Poor match, fundamental incompatibilities
    PROMPT
  end

  def screening_prompt(init_ctx, cand_ctx)
    <<~PROMPT
      Evaluate the compatibility of these two people for a potential date:

      === PERSON A ===
      #{init_ctx.full_context}

      === PERSON B ===
      #{cand_ctx.full_context}

      Consider: relationship goals, lifestyle compatibility, schedule overlap,
      personality dynamics (MBTI), shared interests from bios, and any dealbreakers.
    PROMPT
  end

  def parse_screening_result(response)
    json_match = response.to_s.match(/\{[\s\S]*\}/)
    if json_match
      parsed = JSON.parse(json_match[0], symbolize_names: true)
      {
        score: parsed[:score].to_f.clamp(0, 100),
        summary: parsed[:summary] || "Screening completed.",
        reasoning: parsed[:reasoning] || response.to_s
      }
    else
      { score: 50.0, summary: "Screening completed with unstructured response.", reasoning: response.to_s }
    end
  rescue JSON::ParserError
    { score: 50.0, summary: "Screening completed.", reasoning: response.to_s }
  end
end
