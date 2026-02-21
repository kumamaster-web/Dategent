# frozen_string_literal: true

require "rails_helper"

RSpec.describe CandidateFinder, type: :service do
  # Test user — male, looking for female, age 24-35
  let!(:user) do
    create_full_user(
      { first_name: "Alex", gender: "male", date_of_birth: Date.new(1994, 6, 15) },
      { preferred_gender: "female", min_age: 24, max_age: 35 }
    )
  end

  # Matching candidate — female, in age range, active agent
  let!(:good_candidate) do
    create_full_user(
      { first_name: "Sarah", gender: "female", date_of_birth: Date.new(1996, 3, 22) },
      { preferred_gender: "male", min_age: 25, max_age: 36 }
    )
  end

  # Wrong gender
  let!(:wrong_gender) do
    create_full_user(
      { first_name: "Marcus", gender: "male", date_of_birth: Date.new(1993, 5, 10) },
      { preferred_gender: "female", min_age: 25, max_age: 36 }
    )
  end

  # Too young (age 20 — below min_age 24)
  let!(:too_young) do
    create_full_user(
      { first_name: "Young", gender: "female", date_of_birth: Date.new(2005, 1, 1) },
      { preferred_gender: "male", min_age: 20, max_age: 30 }
    )
  end

  # Too old (age 40 — above max_age 35)
  let!(:too_old) do
    create_full_user(
      { first_name: "Older", gender: "female", date_of_birth: Date.new(1985, 1, 1) },
      { preferred_gender: "male", min_age: 30, max_age: 50 }
    )
  end

  subject(:finder) { described_class.new(user) }

  describe "#call" do
    it "returns the matching candidate" do
      results = finder.call
      expect(results).to include(good_candidate)
    end

    it "excludes users with wrong gender" do
      results = finder.call
      expect(results).not_to include(wrong_gender)
    end

    it "excludes users who are too young" do
      results = finder.call
      expect(results).not_to include(too_young)
    end

    it "excludes users who are too old" do
      results = finder.call
      expect(results).not_to include(too_old)
    end

    it "excludes self" do
      results = finder.call
      expect(results).not_to include(user)
    end

    context "when user has blocked a candidate" do
      before do
        Block.create!(blocker_user: user, blocked_user: good_candidate)
      end

      it "excludes the blocked user" do
        results = finder.call
        expect(results).not_to include(good_candidate)
      end
    end

    context "when a candidate has blocked the user" do
      before do
        Block.create!(blocker_user: good_candidate, blocked_user: user)
      end

      it "excludes the blocker" do
        results = finder.call
        expect(results).not_to include(good_candidate)
      end
    end

    context "when a match already exists" do
      before do
        Match.create!(
          initiator_agent: user.agent,
          receiver_agent: good_candidate.agent,
          status: "screening",
          compatibility_score: 0.0
        )
      end

      it "excludes already-matched users" do
        results = finder.call
        expect(results).not_to include(good_candidate)
      end
    end

    context "when candidate's agent is inactive" do
      before do
        good_candidate.agent.update!(status: "inactive")
      end

      it "excludes users with inactive agents" do
        results = finder.call
        expect(results).not_to include(good_candidate)
      end
    end

    context "when weekly match cap is exceeded" do
      before do
        # Fill up the user's weekly cap with matches
        user.agent.match_cap_per_week.times do |i|
          other = create_full_user(
            { first_name: "Fill#{i}", gender: "female", date_of_birth: Date.new(1995, 1, 1) },
            { preferred_gender: "male", min_age: 25, max_age: 35 }
          )
          Match.create!(
            initiator_agent: user.agent,
            receiver_agent: other.agent,
            status: "screening",
            compatibility_score: 0.0,
            created_at: Time.current # This week
          )
        end
      end

      it "returns no candidates when cap is reached" do
        results = finder.call
        expect(results).to be_empty
      end
    end
  end
end
