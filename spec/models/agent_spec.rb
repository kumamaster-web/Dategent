# frozen_string_literal: true

require "rails_helper"

RSpec.describe Agent, type: :model do
  let(:user) { create_user }
  let(:agent) { create_agent(user) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(agent).to be_valid
    end

    it "validates uniqueness of user_id" do
      agent # create first
      duplicate = Agent.new(user: user, match_cap_per_week: 5)
      expect(duplicate).not_to be_valid
    end

    it "validates match_cap_per_week is between 1 and 10" do
      agent.match_cap_per_week = 0
      expect(agent).not_to be_valid

      agent.match_cap_per_week = 11
      expect(agent).not_to be_valid

      agent.match_cap_per_week = 5
      expect(agent).to be_valid
    end

    it "validates personality_mode inclusion" do
      agent.personality_mode = "invalid"
      expect(agent).not_to be_valid

      %w[friendly professional witty caring direct].each do |mode|
        agent.personality_mode = mode
        expect(agent).to be_valid
      end
    end
  end

  describe "#active?" do
    it "returns true when status is active" do
      agent.status = "active"
      expect(agent.active?).to be true
    end

    it "returns false when status is not active" do
      agent.status = "inactive"
      expect(agent.active?).to be false
    end
  end

  describe "#autopilot?" do
    it "returns true when autopilot is true" do
      agent.autopilot = true
      expect(agent.autopilot?).to be true
    end

    it "returns false when autopilot is false" do
      agent.autopilot = false
      expect(agent.autopilot?).to be false
    end
  end

  describe "#aggressiveness_level" do
    it "returns conservative for low cap" do
      agent.match_cap_per_week = 1
      expect(agent.aggressiveness_level).to eq("conservative")
    end

    it "returns moderate for medium cap" do
      agent.match_cap_per_week = 4
      expect(agent.aggressiveness_level).to eq("moderate")
    end

    it "returns active for high cap" do
      agent.match_cap_per_week = 8
      expect(agent.aggressiveness_level).to eq("active")
    end
  end

  describe "#all_matches" do
    let(:other_user) { create_user(first_name: "Other") }
    let(:other_agent) { create_agent(other_user) }

    it "returns matches where agent is initiator" do
      match = Match.create!(initiator_agent: agent, receiver_agent: other_agent, status: "screening", compatibility_score: 0)
      expect(agent.all_matches).to include(match)
    end

    it "returns matches where agent is receiver" do
      match = Match.create!(initiator_agent: other_agent, receiver_agent: agent, status: "screening", compatibility_score: 0)
      expect(agent.all_matches).to include(match)
    end
  end
end
