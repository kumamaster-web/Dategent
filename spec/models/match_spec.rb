# frozen_string_literal: true

require "rails_helper"

RSpec.describe Match, type: :model do
  let(:user_a) { create_user(first_name: "Alex") }
  let(:user_b) { create_user(first_name: "Sarah") }
  let(:agent_a) { create_agent(user_a) }
  let(:agent_b) { create_agent(user_b) }

  let(:match) do
    Match.create!(
      initiator_agent: agent_a,
      receiver_agent: agent_b,
      status: "screening",
      compatibility_score: 0.0
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(match).to be_valid
    end

    it "validates status inclusion" do
      match.status = "invalid_status"
      expect(match).not_to be_valid
    end

    it "accepts all valid statuses" do
      %w[screening evaluating date_proposed confirmed declined].each do |status|
        match.status = status
        expect(match).to be_valid, "Expected '#{status}' to be valid"
      end
    end
  end

  describe "status query methods" do
    it "responds to screening?" do
      match.status = "screening"
      expect(match.screening?).to be true
      expect(match.evaluating?).to be false
    end

    it "responds to evaluating?" do
      match.status = "evaluating"
      expect(match.evaluating?).to be true
      expect(match.screening?).to be false
    end

    it "responds to date_proposed?" do
      match.status = "date_proposed"
      expect(match.date_proposed?).to be true
    end

    it "responds to confirmed?" do
      match.status = "confirmed"
      expect(match.confirmed?).to be true
    end

    it "responds to declined?" do
      match.status = "declined"
      expect(match.declined?).to be true
    end
  end

  describe "#initiator_user" do
    it "returns the initiator agent's user" do
      expect(match.initiator_user).to eq(user_a)
    end
  end

  describe "#receiver_user" do
    it "returns the receiver agent's user" do
      expect(match.receiver_user).to eq(user_b)
    end
  end

  describe "STATUSES constant" do
    it "includes all expected statuses" do
      expect(Match::STATUSES).to eq(%w[screening evaluating date_proposed confirmed declined])
    end
  end

  describe "#transcript_history" do
    it "returns transcripts in stage order" do
      # Create out of order
      MatchTranscript.create!(match: match, stage: "evaluating", content: "Eval content")
      MatchTranscript.create!(match: match, stage: "screening", content: "Screen content")

      history = match.transcript_history
      expect(history.map(&:stage)).to eq(%w[screening evaluating])
    end

    it "returns empty array when no transcripts exist" do
      expect(match.transcript_history).to be_empty
    end
  end

  describe "#record_transcript!" do
    it "creates a new transcript for a stage" do
      expect {
        match.record_transcript!("screening", "Screening conversation")
      }.to change(MatchTranscript, :count).by(1)

      transcript = match.match_transcripts.find_by(stage: "screening")
      expect(transcript.content).to eq("Screening conversation")
    end

    it "updates existing transcript for the same stage (idempotent)" do
      match.record_transcript!("screening", "Original screening")
      expect {
        match.record_transcript!("screening", "Updated screening")
      }.not_to change(MatchTranscript, :count)

      transcript = match.match_transcripts.find_by(stage: "screening")
      expect(transcript.content).to eq("Updated screening")
    end
  end

  # ── Compatibility Breakdown Accessors ─────────────────────────────

  describe "#breakdown" do
    it "returns an empty hash with indifferent access when no breakdown exists" do
      expect(match.breakdown).to eq({})
      expect(match.breakdown).to be_a(ActiveSupport::HashWithIndifferentAccess)
    end

    it "returns breakdown data with indifferent access" do
      match.update!(compatibility_breakdown: { personality: { user_mbti: "ENFJ" } })
      expect(match.breakdown[:personality][:user_mbti]).to eq("ENFJ")
      expect(match.breakdown["personality"]["user_mbti"]).to eq("ENFJ")
    end
  end

  describe "#has_breakdown?" do
    it "returns false when breakdown is empty" do
      expect(match.has_breakdown?).to be false
    end

    it "returns true when breakdown has data" do
      match.update!(compatibility_breakdown: { personality: { user_mbti: "ENFJ" } })
      expect(match.has_breakdown?).to be true
    end
  end

  describe "#personality_breakdown" do
    it "returns personality section" do
      match.update!(compatibility_breakdown: {
        personality: { user_mbti: "ENFJ", match_mbti: "INFP", compatibility_label: "complementary" }
      })
      expect(match.personality_breakdown["user_mbti"]).to eq("ENFJ")
      expect(match.personality_breakdown["compatibility_label"]).to eq("complementary")
    end

    it "returns empty hash when no personality data" do
      expect(match.personality_breakdown).to eq({})
    end
  end

  describe "#lifestyle_breakdown" do
    it "returns lifestyle section with alignment score" do
      match.update!(compatibility_breakdown: {
        lifestyle: { alignment_score: 3, factors: {} }
      })
      expect(match.lifestyle_breakdown["alignment_score"]).to eq(3)
    end
  end

  describe "#schedule_breakdown" do
    it "returns schedule section with overlap data" do
      match.update!(compatibility_breakdown: {
        schedule: { overlap_slots: 5, overlap_minutes: 150, overlap_percentage: 62, best_days: ["saturday"] }
      })
      expect(match.schedule_breakdown["overlap_percentage"]).to eq(62)
      expect(match.schedule_breakdown["best_days"]).to eq(["saturday"])
    end
  end

  describe "#shared_interests_breakdown" do
    it "returns shared interests section" do
      match.update!(compatibility_breakdown: {
        shared_interests: { interests: ["hiking", "cooking"], commentary: "Both love outdoors" }
      })
      expect(match.shared_interests_breakdown["interests"]).to eq(["hiking", "cooking"])
    end
  end

  describe "#unique_insights" do
    it "returns array of insights" do
      match.update!(compatibility_breakdown: {
        unique_insights: ["Great personality match", "Both love food"]
      })
      expect(match.unique_insights).to eq(["Great personality match", "Both love food"])
    end

    it "returns empty array when no insights" do
      expect(match.unique_insights).to eq([])
    end
  end

  describe "#dealbreaker_list" do
    it "returns array of dealbreakers" do
      match.update!(compatibility_breakdown: {
        dealbreakers: ["Smoking mismatch"]
      })
      expect(match.dealbreaker_list).to eq(["Smoking mismatch"])
    end

    it "returns empty array when no dealbreakers" do
      expect(match.dealbreaker_list).to eq([])
    end
  end
end
