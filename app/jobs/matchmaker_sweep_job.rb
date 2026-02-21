# frozen_string_literal: true

# Top-level sweep job — enqueues MatchmakerJob for every active autopilot agent.
#
# Schedule: Run daily via Heroku Scheduler or Sidekiq-Cron
#   rails runner "MatchmakerSweepJob.perform_later"
class MatchmakerSweepJob < ApplicationJob
  queue_as :low

  def perform
    agents = Agent.where(status: "active", autopilot: true)

    Rails.logger.info "[MatchmakerSweepJob] Starting sweep for #{agents.count} active autopilot agents"

    agents.find_each do |agent|
      MatchmakerJob.perform_later(agent.user_id)
    end

    Rails.logger.info "[MatchmakerSweepJob] Sweep complete — #{agents.count} jobs enqueued"
  end
end
