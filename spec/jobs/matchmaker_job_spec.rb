# frozen_string_literal: true

require "rails_helper"

RSpec.describe MatchmakerJob, type: :job do
  let!(:user) do
    create_full_user(
      { first_name: "Alex", gender: "male", date_of_birth: Date.new(1994, 6, 15) },
      { preferred_gender: "female", min_age: 24, max_age: 35 },
      { autopilot: true, status: "active", match_cap_per_week: 5 }
    )
  end

  let!(:candidate) do
    create_full_user(
      { first_name: "Sarah", gender: "female", date_of_birth: Date.new(1996, 3, 22) },
      { preferred_gender: "male", min_age: 25, max_age: 36 },
      { autopilot: true, status: "active" }
    )
  end

  describe "#perform" do
    it "enqueues ScreeningJob for matching candidates" do
      expect {
        described_class.perform_now(user.id)
      }.to have_enqueued_job(ScreeningJob).with(user.id, candidate.id)
    end

    it "does not enqueue if agent is not autopilot" do
      user.agent.update!(autopilot: false)
      expect {
        described_class.perform_now(user.id)
      }.not_to have_enqueued_job(ScreeningJob)
    end

    it "does not enqueue if agent is inactive" do
      user.agent.update!(status: "inactive")
      expect {
        described_class.perform_now(user.id)
      }.not_to have_enqueued_job(ScreeningJob)
    end

    it "skips candidates who already have a reverse match" do
      # Create a match where candidate initiated
      Match.create!(
        initiator_agent: candidate.agent,
        receiver_agent: user.agent,
        status: "screening",
        compatibility_score: 0.0
      )

      expect {
        described_class.perform_now(user.id)
      }.not_to have_enqueued_job(ScreeningJob)
    end
  end
end
