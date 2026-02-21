# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScreeningJob, type: :job do
  let!(:initiator) do
    create_full_user(
      { first_name: "Alex", gender: "male", date_of_birth: Date.new(1994, 6, 15) },
      { preferred_gender: "female", min_age: 24, max_age: 35 }
    )
  end

  let!(:candidate) do
    create_full_user(
      { first_name: "Sarah", gender: "female", date_of_birth: Date.new(1996, 3, 22) },
      { preferred_gender: "male", min_age: 25, max_age: 36 }
    )
  end

  let(:high_score_response) do
    '{"score": 82, "summary": "Strong compatibility.", "reasoning": "Both value outdoor activities.", "dealbreakers": []}'
  end

  let(:low_score_response) do
    '{"score": 35, "summary": "Poor match.", "reasoning": "Fundamental lifestyle differences.", "dealbreakers": ["smoking"]}'
  end

  let(:mock_llm_response) { double("RubyLLM::Message", content: high_score_response) }
  let(:mock_chat) { instance_double(Chat) }

  before do
    allow(Chat).to receive(:create!).and_return(mock_chat)
    allow(mock_chat).to receive(:with_instructions).and_return(mock_chat)
    allow(mock_chat).to receive(:ask).and_return(mock_llm_response)
  end

  describe "#perform" do
    context "with a high compatibility score" do
      it "creates a match record" do
        expect {
          described_class.perform_now(initiator.id, candidate.id)
        }.to change(Match, :count).by(1)
      end

      it "sets the match status to evaluating" do
        described_class.perform_now(initiator.id, candidate.id)
        match = Match.last
        expect(match.status).to eq("evaluating")
      end

      it "saves the compatibility score" do
        described_class.perform_now(initiator.id, candidate.id)
        match = Match.last
        expect(match.compatibility_score).to eq(82.0)
      end

      it "saves the compatibility summary" do
        described_class.perform_now(initiator.id, candidate.id)
        match = Match.last
        expect(match.compatibility_summary).to eq("Strong compatibility.")
      end

      it "enqueues NegotiationJob" do
        expect {
          described_class.perform_now(initiator.id, candidate.id)
        }.to have_enqueued_job(NegotiationJob)
      end
    end

    context "with a low compatibility score" do
      let(:mock_llm_response) { double("RubyLLM::Message", content: low_score_response) }

      it "sets the match status to declined" do
        described_class.perform_now(initiator.id, candidate.id)
        match = Match.last
        expect(match.status).to eq("declined")
      end

      it "does not enqueue NegotiationJob" do
        expect {
          described_class.perform_now(initiator.id, candidate.id)
        }.not_to have_enqueued_job(NegotiationJob)
      end

      it "saves the score" do
        described_class.perform_now(initiator.id, candidate.id)
        match = Match.last
        expect(match.compatibility_score).to eq(35.0)
      end
    end

    context "when LLM returns non-JSON" do
      let(:mock_llm_response) { double("RubyLLM::Message", content: "This is just text, not JSON.") }

      it "uses fallback score of 50" do
        described_class.perform_now(initiator.id, candidate.id)
        match = Match.last
        expect(match.compatibility_score).to eq(50.0)
      end
    end

    context "when match already exists past screening" do
      before do
        Match.create!(
          initiator_agent: initiator.agent,
          receiver_agent: candidate.agent,
          status: "evaluating",
          compatibility_score: 75.0
        )
      end

      it "does not re-process the match (idempotent)" do
        expect(mock_chat).not_to receive(:ask)
        described_class.perform_now(initiator.id, candidate.id)
      end
    end
  end
end
