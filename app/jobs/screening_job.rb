# frozen_string_literal: true

# Uses RubyLLM to evaluate compatibility between two users via a single
# LLM call. Creates a Match record and either advances to NegotiationJob
# (score >= threshold) or declines.
#
# Pipeline: MatchmakerJob → ScreeningJob → NegotiationJob (if passed)
class ScreeningJob < ApplicationJob
  queue_as :default
  retry_on RubyLLM::ServiceUnavailableError, wait: :polynomially_longer, attempts: 5
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  SCREENING_THRESHOLD = 60.0

  def perform(initiator_user_id, candidate_user_id)
    initiator = User.includes(:user_preference, :agent).find(initiator_user_id)
    candidate = User.includes(:user_preference, :agent).find(candidate_user_id)

    Rails.logger.info "[ScreeningJob] START: #{initiator.first_name} ↔ #{candidate.first_name}"

    init_ctx = AgentContextBuilder.new(initiator)
    cand_ctx = AgentContextBuilder.new(candidate)

    # Compute deterministic compatibility facts before LLM call
    Rails.logger.info "[ScreeningJob] Computing deterministic breakdown..."
    breakdown = CompatibilityBreakdownBuilder.new(initiator, candidate).call

    # Create or find the match in screening status
    match = Match.find_or_create_by!(
      initiator_agent: initiator.agent,
      receiver_agent: candidate.agent
    ) do |m|
      m.status = "screening"
      m.compatibility_score = 0.0
    end

    # Skip if already past screening (idempotency guard)
    unless match.screening?
      Rails.logger.info "[ScreeningJob] SKIP: Match ##{match.id} already #{match.status}"
      return
    end

    # RubyLLM persisted Chat — system prompt + single evaluation call
    Rails.logger.info "[ScreeningJob] Building context and calling Gemini..."
    chat = Chat.create!
    chat.with_instructions(screening_system_prompt)
    response = chat.ask(screening_prompt(init_ctx, cand_ctx, breakdown))
    Rails.logger.info "[ScreeningJob] Gemini responded. Parsing result..."

    result = parse_screening_result(response.content)

    # Merge LLM commentary into the deterministic breakdown
    merged_breakdown = merge_breakdown(breakdown, result)

    new_status = result[:score] >= SCREENING_THRESHOLD ? "evaluating" : "declined"

    match.update!(
      compatibility_score: result[:score],
      compatibility_summary: result[:summary],
      compatibility_breakdown: merged_breakdown,
      chat_transcript: result[:reasoning],
      status: new_status
    )

    # Persist stage transcript for history
    match.record_transcript!("screening", result[:reasoning])

    # Advance to agent-to-agent negotiation if passed screening
    if match.evaluating?
      Rails.logger.info "[ScreeningJob] PASS (#{result[:score]} >= #{SCREENING_THRESHOLD}). Enqueuing NegotiationJob for Match ##{match.id}"
      NegotiationJob.perform_later(match.id)
    else
      Rails.logger.info "[ScreeningJob] DECLINED (#{result[:score]} < #{SCREENING_THRESHOLD}). Match ##{match.id}"
    end

    Rails.logger.info "[ScreeningJob] DONE: #{initiator.first_name} ↔ #{candidate.first_name} → #{new_status} (score: #{result[:score]})"
  rescue JSON::ParserError => e
    Rails.logger.error "[ScreeningJob] JSON parse error: #{e.message}"
    Rails.logger.error "[ScreeningJob] Raw response: #{response&.content.to_s.truncate(500)}"
    raise
  rescue => e
    Rails.logger.error "[ScreeningJob] ERROR: #{e.class} — #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
    raise
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
        "dealbreakers": ["<list any dealbreakers found>"],
        "category_commentary": {
          "personality": "<1-2 sentences interpreting the MBTI pairing dynamics>",
          "relationship_goal": "<1-2 sentences on goal alignment nuance>",
          "lifestyle": "<1-2 sentences on what lifestyle factor differences mean in practice>",
          "schedule": "<1-2 sentences on practical scheduling implications>",
          "shared_interests": "<1-2 sentences on common ground inferred from bios>"
        },
        "shared_interests_identified": ["<list of shared interest tags inferred from both bios>"],
        "unique_insights": ["<1-3 match-specific observations not covered by the categories above>"]
      }

      Scoring guide:
      - 80-100: Excellent match, strong alignment on values and lifestyle
      - 60-79: Good match, some differences but worth exploring
      - 40-59: Marginal, significant gaps in key areas
      - 0-39: Poor match, fundamental incompatibilities
    PROMPT
  end

  def screening_prompt(init_ctx, cand_ctx, breakdown)
    <<~PROMPT
      Evaluate the compatibility of these two people for a potential date:

      === PERSON A ===
      #{init_ctx.full_context}

      === PERSON B ===
      #{cand_ctx.full_context}

      === FACTUAL COMPARISON (already computed) ===
      Personality: Person A is #{breakdown[:personality][:user_mbti] || 'unknown'}, Person B is #{breakdown[:personality][:match_mbti] || 'unknown'} — pre-classified as "#{breakdown[:personality][:compatibility_label]}"
      Relationship Goal: Person A wants "#{breakdown[:relationship_goal][:user_goal] || 'unknown'}", Person B wants "#{breakdown[:relationship_goal][:match_goal] || 'unknown'}" — pre-classified as "#{breakdown[:relationship_goal][:alignment]}"
      Lifestyle Alignment: #{breakdown[:lifestyle][:alignment_score]}/4 factors aligned (#{lifestyle_factor_summary(breakdown[:lifestyle][:factors])})
      Schedule Overlap: #{breakdown[:schedule][:overlap_minutes]} minutes/week across #{breakdown[:schedule][:best_days].join(', ').presence || 'no days'}

      Based on these factual comparisons and the full profiles above, provide your nuanced commentary per category,
      identify shared interests from both bios, and note any unique insights about this specific pairing.
    PROMPT
  end

  def lifestyle_factor_summary(factors)
    factors.map do |factor, data|
      status = data[:aligned] ? "✓" : "✗"
      "#{factor}: #{data[:user_value] || '?'} vs #{data[:match_value] || '?'} #{status}"
    end.join(", ")
  end

  def parse_screening_result(response)
    json_match = response.to_s.match(/\{[\s\S]*\}/)
    if json_match
      parsed = JSON.parse(json_match[0], symbolize_names: true)
      {
        score: parsed[:score].to_f.clamp(0, 100),
        summary: parsed[:summary] || "Screening completed.",
        reasoning: parsed[:reasoning] || response.to_s,
        dealbreakers: Array(parsed[:dealbreakers]),
        category_commentary: parsed[:category_commentary] || {},
        shared_interests: Array(parsed[:shared_interests_identified]),
        unique_insights: Array(parsed[:unique_insights])
      }
    else
      {
        score: 50.0,
        summary: "Screening completed with unstructured response.",
        reasoning: response.to_s,
        dealbreakers: [],
        category_commentary: {},
        shared_interests: [],
        unique_insights: []
      }
    end
  rescue JSON::ParserError
    {
      score: 50.0,
      summary: "Screening completed.",
      reasoning: response.to_s,
      dealbreakers: [],
      category_commentary: {},
      shared_interests: [],
      unique_insights: []
    }
  end

  def merge_breakdown(breakdown, llm_result)
    commentary = llm_result[:category_commentary]

    breakdown[:personality][:commentary] = commentary[:personality]
    breakdown[:relationship_goal][:commentary] = commentary[:relationship_goal]
    breakdown[:lifestyle][:commentary] = commentary[:lifestyle]
    breakdown[:schedule][:commentary] = commentary[:schedule]
    breakdown[:shared_interests] = {
      interests: llm_result[:shared_interests],
      commentary: commentary[:shared_interests]
    }
    breakdown[:unique_insights] = llm_result[:unique_insights]
    breakdown[:dealbreakers] = llm_result[:dealbreakers]

    breakdown
  end
end
