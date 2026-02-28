# frozen_string_literal: true

# Finds candidate matches for a single user using SQL hard-filters,
# then enqueues a ScreeningJob for each candidate pair.
class MatchmakerJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.includes(:user_preference, :agent).find(user_id)
    agent = user.agent

    Rails.logger.info "[MatchmakerJob] START for #{user.first_name} #{user.last_name} (ID: #{user_id})"

    unless agent&.active?
      Rails.logger.info "[MatchmakerJob] SKIP: Agent not active"
      return
    end
    unless agent&.autopilot?
      Rails.logger.info "[MatchmakerJob] SKIP: Agent not on autopilot"
      return
    end

    candidates = CandidateFinder.new(user).call
    Rails.logger.info "[MatchmakerJob] Found #{candidates.count} candidates"
    enqueued = 0

    candidates.find_each do |candidate|
      # Skip if the reverse direction match already exists
      next if Match.exists?(
        initiator_agent: candidate.agent,
        receiver_agent: agent
      )

      ScreeningJob.perform_later(user.id, candidate.id)
      enqueued += 1
      Rails.logger.info "[MatchmakerJob] Enqueued screening: #{user.first_name} ↔ #{candidate.first_name}"
    end

    Rails.logger.info "[MatchmakerJob] DONE: #{enqueued} screening jobs enqueued"
  rescue => e
    Rails.logger.error "[MatchmakerJob] ERROR: #{e.class} — #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
    raise
  end
end
