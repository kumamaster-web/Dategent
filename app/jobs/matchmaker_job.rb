# frozen_string_literal: true

# Finds candidate matches for a single user using SQL hard-filters,
# then enqueues a ScreeningJob for each candidate pair.
class MatchmakerJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.includes(:user_preference, :agent).find(user_id)
    agent = user.agent

    return unless agent&.active?
    return unless agent&.autopilot?

    candidates = CandidateFinder.new(user).call
    enqueued = 0

    candidates.find_each do |candidate|
      # Skip if the reverse direction match already exists
      next if Match.exists?(
        initiator_agent: candidate.agent,
        receiver_agent: agent
      )

      ScreeningJob.perform_later(user.id, candidate.id)
      enqueued += 1
    end

    Rails.logger.info "[MatchmakerJob] User ##{user_id} (#{user.first_name}): " \
                      "#{enqueued} screening jobs enqueued"
  end
end
