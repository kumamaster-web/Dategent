# frozen_string_literal: true

require "rails_helper"

RSpec.describe NegotiationJob, type: :job do
  let!(:initiator) do
    create_full_user(
      { first_name: "Alex", gender: "male" },
      {
        preferred_venue_types: %w[dinner drinks],
        budget_level: "$$$",
        schedule_availability: { "saturday" => %w[18:00 18:30 19:00] }
      }
    )
  end

  let!(:receiver) do
    create_full_user(
      { first_name: "Sarah", gender: "female" },
      {
        preferred_venue_types: %w[dinner outdoor],
        budget_level: "$$",
        schedule_availability: { "saturday" => %w[18:00 18:30 19:00 19:30] }
      }
    )
  end

  let!(:venue) do
    create_venue(name: "Sakana-ya Uoharu", venue_type: "dinner", price_tier: 2, rating: 4.4)
  end

  let!(:match) do
    Match.create!(
      initiator_agent: initiator.agent,
      receiver_agent: receiver.agent,
      status: "evaluating",
      compatibility_score: 82.0,
      compatibility_summary: "Strong compatibility signals."
    )
  end

  let(:propose_response_content) do
    "Great conversation! I think our people would really enjoy meeting.\n\n" \
    "DECISION: PROPOSE_DATE | venue: Sakana-ya Uoharu | time: 2026-03-01T19:00:00+09:00"
  end

  let(:decline_response_content) do
    "After careful consideration, I don't think this is the right match.\n\n" \
    "DECISION: DECLINE | reason: Schedule incompatibility and different relationship goals"
  end

  let(:neutral_response_content) do
    "That sounds interesting! Tell me more about your person's interests in outdoor activities."
  end

  # Mock the Chat / LLM interaction
  let(:mock_chat_a) { instance_double(Chat) }
  let(:mock_chat_b) { instance_double(Chat) }

  before do
    allow(Chat).to receive(:create!).and_return(mock_chat_a, mock_chat_b)
    allow(mock_chat_a).to receive(:with_instructions).and_return(mock_chat_a)
    allow(mock_chat_b).to receive(:with_instructions).and_return(mock_chat_b)
  end

  describe "#perform" do
    context "when agents agree on a date" do
      before do
        opening = double("RubyLLM::Message", content: neutral_response_content)
        proposal = double("RubyLLM::Message", content: propose_response_content)

        allow(mock_chat_a).to receive(:ask).and_return(opening)
        allow(mock_chat_b).to receive(:ask).and_return(proposal)
      end

      it "updates the match status to date_proposed" do
        described_class.perform_now(match.id)
        match.reload
        expect(match.status).to eq("date_proposed")
      end

      it "creates a DateEvent" do
        expect {
          described_class.perform_now(match.id)
        }.to change(DateEvent, :count).by(1)
      end

      it "sets the DateEvent to proposed booking_status" do
        described_class.perform_now(match.id)
        date_event = DateEvent.last
        expect(date_event.booking_status).to eq("proposed")
      end

      it "assigns the venue to the DateEvent" do
        described_class.perform_now(match.id)
        date_event = DateEvent.last
        expect(date_event.venue).to eq(venue)
      end

      it "stores the transcript on the match" do
        described_class.perform_now(match.id)
        match.reload
        expect(match.chat_transcript).to include("Alex's Agent")
      end
    end

    context "when agents decline" do
      before do
        opening = double("RubyLLM::Message", content: neutral_response_content)
        decline = double("RubyLLM::Message", content: decline_response_content)

        allow(mock_chat_a).to receive(:ask).and_return(opening)
        allow(mock_chat_b).to receive(:ask).and_return(decline)
      end

      it "updates the match status to declined" do
        described_class.perform_now(match.id)
        match.reload
        expect(match.status).to eq("declined")
      end

      it "does not create a DateEvent" do
        expect {
          described_class.perform_now(match.id)
        }.not_to change(DateEvent, :count)
      end

      it "stores the decline reason in compatibility_summary" do
        described_class.perform_now(match.id)
        match.reload
        expect(match.compatibility_summary).to include("Declined:")
      end
    end

    context "when match is not in evaluating status" do
      before do
        match.update!(status: "confirmed")
      end

      it "skips processing" do
        expect(Chat).not_to receive(:create!)
        described_class.perform_now(match.id)
      end
    end

    context "when agents reach max turns without decision" do
      before do
        neutral = double("RubyLLM::Message", content: neutral_response_content)
        allow(mock_chat_a).to receive(:ask).and_return(neutral)
        allow(mock_chat_b).to receive(:ask).and_return(neutral)
      end

      it "defaults to decline" do
        described_class.perform_now(match.id)
        match.reload
        expect(match.status).to eq("declined")
      end
    end
  end
end
