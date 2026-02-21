# frozen_string_literal: true

# Multi-turn agent-to-agent conversation using RubyLLM.
# Two separate Chat instances (one per agent) exchange messages
# until they agree on a date proposal or decline.
#
# Pipeline: ScreeningJob → NegotiationJob → DateEvent created (or declined)
class NegotiationJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  MAX_TURNS = 8

  def perform(match_id)
    @match = Match.find(match_id)
    return unless @match.evaluating?

    init_user = @match.initiator_agent.user
    recv_user = @match.receiver_agent.user

    @init_ctx = AgentContextBuilder.new(init_user)
    @recv_ctx = AgentContextBuilder.new(recv_user)

    @schedule_overlap = ScheduleOverlapService.new(init_user, recv_user).call
    @venue_options = VenueFinderService.new(init_user, recv_user).call

    # Two separate RubyLLM Chats — one per agent, fully persisted
    agent_a_chat = Chat.create!
    agent_a_chat.with_instructions(agent_system_context(@init_ctx))

    agent_b_chat = Chat.create!
    agent_b_chat.with_instructions(agent_system_context(@recv_ctx))

    transcript = []

    # Agent A opens the conversation
    a_opening_response = agent_a_chat.ask(agent_a_opening_prompt)
    a_opening = a_opening_response.content.to_s
    transcript << { speaker: @match.initiator_agent.name, message: a_opening }

    MAX_TURNS.times do
      # Agent B responds to what Agent A said
      b_response = agent_b_chat.ask(agent_reply_prompt(transcript))
      b_content = b_response.content.to_s
      transcript << { speaker: @match.receiver_agent.name, message: b_content }

      break if decision_reached?(b_content)

      # Agent A responds to Agent B
      a_response = agent_a_chat.ask(agent_reply_prompt(transcript))
      a_content = a_response.content.to_s
      transcript << { speaker: @match.initiator_agent.name, message: a_content }

      break if decision_reached?(a_content)
    end

    decision = extract_decision(transcript)
    finalize_match(decision, transcript)

    Rails.logger.info "[NegotiationJob] Match ##{@match.id}: #{decision[:action]} " \
                      "(#{transcript.size} messages)"
  end

  private

  def agent_system_context(ctx)
    "#{ctx.system_prompt}\n\n#{ctx.full_context}\n\n#{negotiation_rules}"
  end

  def negotiation_rules
    venue_list = @venue_options.map { |v| "#{v.name} (#{v.venue_type}, tier #{v.price_tier})" }.join("; ")

    <<~RULES
      NEGOTIATION RULES:
      - Discuss compatibility, shared interests, and date logistics
      - Schedule overlap data: #{@schedule_overlap.to_json}
      - Available venues: #{venue_list}
      - When you reach agreement on a venue and time, respond with EXACTLY:
        DECISION: PROPOSE_DATE | venue: <name> | time: <ISO 8601 datetime>
      - If you determine incompatibility, respond with EXACTLY:
        DECISION: DECLINE | reason: <brief reason>
      - You MUST reach a DECISION within your conversation
    RULES
  end

  def agent_a_opening_prompt
    <<~PROMPT
      You're initiating a conversation with another dating agent. Your person scored
      #{@match.compatibility_score}/100 in initial screening.

      Open the conversation by highlighting what excited you about this potential match.
      Discuss compatibility without revealing private details.
      Work toward agreeing on a date venue and time.
    PROMPT
  end

  def agent_reply_prompt(transcript)
    <<~PROMPT
      Conversation so far:

      #{format_transcript(transcript)}

      Continue the negotiation. Address questions or concerns raised.
      Work toward a concrete date proposal or a respectful decline.
    PROMPT
  end

  def format_transcript(transcript)
    transcript.map { |t| "[#{t[:speaker]}]: #{t[:message]}" }.join("\n\n")
  end

  def decision_reached?(content)
    content.include?("DECISION: PROPOSE_DATE") || content.include?("DECISION: DECLINE")
  end

  def extract_decision(transcript)
    last_messages = transcript.last(3).map { |t| t[:message] }.join("\n")

    if last_messages.include?("DECISION: PROPOSE_DATE")
      venue_match = last_messages.match(/venue:\s*(.+?)(?:\s*\||\s*$)/i)
      time_match = last_messages.match(/time:\s*(.+?)(?:\s*\||\s*$)/i)
      {
        action: :propose,
        venue_name: venue_match&.captures&.first&.strip,
        time: time_match&.captures&.first&.strip
      }
    else
      reason_match = last_messages.match(/reason:\s*(.+?)$/i)
      { action: :decline, reason: reason_match&.captures&.first&.strip || "Agents could not reach agreement" }
    end
  end

  def finalize_match(decision, transcript)
    formatted = format_transcript(transcript)

    if decision[:action] == :propose
      venue = find_venue(decision[:venue_name])
      scheduled_time = parse_time(decision[:time]) || 5.days.from_now.change(hour: 19)

      @match.update!(status: "date_proposed", chat_transcript: formatted)

      # Persist stage transcripts for history (evaluating + date_proposed)
      @match.record_transcript!("evaluating", formatted)
      @match.record_transcript!("date_proposed", formatted)

      DateEvent.find_or_create_by!(match: @match) do |de|
        de.venue = venue
        de.scheduled_time = scheduled_time
        de.booking_status = "proposed"
      end

      # TODO: Turbo Stream broadcast to both users
    else
      @match.update!(
        status: "declined",
        compatibility_summary: [@match.compatibility_summary, "Declined: #{decision[:reason]}"].compact.join("\n\n"),
        chat_transcript: formatted
      )

      # Persist stage transcript for history
      @match.record_transcript!("declined", formatted)
    end
  end

  def find_venue(venue_name)
    return @venue_options.first if venue_name.blank?

    Venue.find_by("name ILIKE ?", "%#{venue_name}%") || @venue_options.first
  end

  def parse_time(time_string)
    return nil if time_string.blank?
    Time.zone.parse(time_string)
  rescue StandardError
    nil
  end
end
