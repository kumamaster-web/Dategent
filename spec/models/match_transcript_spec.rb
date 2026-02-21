# frozen_string_literal: true

require "rails_helper"

RSpec.describe MatchTranscript, type: :model do
  let(:user_a) { create_user(first_name: "Alex") }
  let(:user_b) { create_user(first_name: "Sarah") }
  let(:agent_a) { create_agent(user_a) }
  let(:agent_b) { create_agent(user_b) }
  let(:match) do
    Match.create!(
      initiator_agent: agent_a,
      receiver_agent: agent_b,
      status: "evaluating",
      compatibility_score: 72.0
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      transcript = MatchTranscript.new(
        match: match,
        stage: "screening",
        content: "Agent A and Agent B discussed compatibility."
      )
      expect(transcript).to be_valid
    end

    it "requires a stage" do
      transcript = MatchTranscript.new(match: match, stage: nil, content: "Content")
      expect(transcript).not_to be_valid
      expect(transcript.errors[:stage]).to be_present
    end

    it "requires content" do
      transcript = MatchTranscript.new(match: match, stage: "screening", content: nil)
      expect(transcript).not_to be_valid
      expect(transcript.errors[:content]).to be_present
    end

    it "validates stage inclusion in STATUSES" do
      transcript = MatchTranscript.new(match: match, stage: "bogus", content: "Content")
      expect(transcript).not_to be_valid
      expect(transcript.errors[:stage]).to be_present
    end

    it "accepts all valid stages" do
      %w[screening evaluating date_proposed confirmed declined].each do |stage|
        transcript = MatchTranscript.new(match: match, stage: stage, content: "Content for #{stage}")
        expect(transcript).to be_valid, "Expected stage '#{stage}' to be valid"
      end
    end

    it "enforces uniqueness of stage per match" do
      MatchTranscript.create!(match: match, stage: "screening", content: "First")
      duplicate = MatchTranscript.new(match: match, stage: "screening", content: "Second")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:stage]).to include("already has a transcript for this stage")
    end

    it "allows same stage for different matches" do
      match_b = Match.create!(
        initiator_agent: agent_b,
        receiver_agent: agent_a,
        status: "screening",
        compatibility_score: 0.0
      )
      MatchTranscript.create!(match: match, stage: "screening", content: "Match A screening")
      transcript_b = MatchTranscript.new(match: match_b, stage: "screening", content: "Match B screening")
      expect(transcript_b).to be_valid
    end
  end

  describe "associations" do
    it "belongs to a match" do
      transcript = MatchTranscript.create!(match: match, stage: "screening", content: "Content")
      expect(transcript.match).to eq(match)
    end
  end

  describe ".chronological" do
    it "returns transcripts ordered by created_at" do
      t1 = MatchTranscript.create!(match: match, stage: "screening", content: "Screening content")
      t2 = MatchTranscript.create!(match: match, stage: "evaluating", content: "Evaluation content")
      expect(MatchTranscript.chronological.to_a).to eq([t1, t2])
    end
  end

  describe "#stage_label" do
    it "returns human-readable label for each stage" do
      expect(MatchTranscript.new(stage: "screening").stage_label).to eq("Initial Screening")
      expect(MatchTranscript.new(stage: "evaluating").stage_label).to eq("Deep Evaluation")
      expect(MatchTranscript.new(stage: "date_proposed").stage_label).to eq("Date Negotiation")
      expect(MatchTranscript.new(stage: "confirmed").stage_label).to eq("Confirmation")
      expect(MatchTranscript.new(stage: "declined").stage_label).to eq("Declined")
    end
  end
end
