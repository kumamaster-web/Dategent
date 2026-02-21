# frozen_string_literal: true

require "rails_helper"

RSpec.describe MatchmakerSweepJob, type: :job do
  let!(:active_autopilot) do
    create_full_user(
      { first_name: "Active" },
      {},
      { autopilot: true, status: "active" }
    )
  end

  let!(:active_manual) do
    create_full_user(
      { first_name: "Manual" },
      {},
      { autopilot: false, status: "active" }
    )
  end

  let!(:inactive_agent) do
    create_full_user(
      { first_name: "Inactive" },
      {},
      { autopilot: true, status: "inactive" }
    )
  end

  describe "#perform" do
    it "enqueues MatchmakerJob for active autopilot agents only" do
      expect {
        described_class.perform_now
      }.to have_enqueued_job(MatchmakerJob).with(active_autopilot.id)
    end

    it "does not enqueue for manual agents" do
      described_class.perform_now
      expect(MatchmakerJob).not_to have_been_enqueued.with(active_manual.id)
    end

    it "does not enqueue for inactive agents" do
      described_class.perform_now
      expect(MatchmakerJob).not_to have_been_enqueued.with(inactive_agent.id)
    end
  end
end
