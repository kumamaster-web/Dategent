# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompatibilityBreakdownBuilder do
  let(:user_a) do
    create_user_with_preference(
      { first_name: "Alex", mbti: "ENFJ" },
      {
        relationship_goal: "serious",
        alcohol: "sometimes", smoking: "never", fitness: "active", budget_level: "$$$",
        schedule_availability: {
          "saturday" => %w[11:00 11:30 12:00 12:30 18:00 18:30 19:00 19:30],
          "wednesday" => %w[19:00 19:30 20:00]
        }
      }
    )
  end

  let(:user_b) do
    create_user_with_preference(
      { first_name: "Sarah", mbti: "INFP" },
      {
        relationship_goal: "serious",
        alcohol: "sometimes", smoking: "never", fitness: "sometimes", budget_level: "$$",
        schedule_availability: {
          "saturday" => %w[10:00 10:30 11:00 11:30 12:00],
          "tuesday" => %w[18:30 19:00 19:30]
        }
      }
    )
  end

  subject { described_class.new(user_a, user_b).call }

  describe "#call" do
    it "returns a hash with all five category keys" do
      expect(subject.keys).to include(:personality, :relationship_goal, :lifestyle, :schedule, :shared_interests)
    end

    it "returns dealbreakers and unique_insights arrays" do
      expect(subject[:dealbreakers]).to eq([])
      expect(subject[:unique_insights]).to eq([])
    end
  end

  describe "personality breakdown" do
    it "includes both MBTI types" do
      expect(subject[:personality][:user_mbti]).to eq("ENFJ")
      expect(subject[:personality][:match_mbti]).to eq("INFP")
    end

    it "computes complementary label for ENFJ-INFP" do
      expect(subject[:personality][:compatibility_label]).to eq("complementary")
    end

    it "has nil commentary (populated by LLM)" do
      expect(subject[:personality][:commentary]).to be_nil
    end
  end

  describe "personality breakdown with different MBTI pairs" do
    context "with similar pair (ENFJ-ENFJ)" do
      let(:user_b) do
        create_user_with_preference(
          { first_name: "Sarah", mbti: "ENFJ" },
          { schedule_availability: { "saturday" => %w[11:00 11:30] } }
        )
      end

      it "returns similar" do
        expect(subject[:personality][:compatibility_label]).to eq("similar")
      end
    end

    context "with challenging pair (ENFJ-ISTP)" do
      let(:user_b) do
        create_user_with_preference(
          { first_name: "James", mbti: "ISTP" },
          { schedule_availability: { "saturday" => %w[11:00 11:30] } }
        )
      end

      it "returns challenging" do
        expect(subject[:personality][:compatibility_label]).to eq("challenging")
      end
    end

    context "with neutral pair (ENFJ-ESFJ)" do
      let(:user_b) do
        create_user_with_preference(
          { first_name: "Yuki", mbti: "ESFJ" },
          { schedule_availability: { "saturday" => %w[11:00 11:30] } }
        )
      end

      it "returns neutral" do
        expect(subject[:personality][:compatibility_label]).to eq("neutral")
      end
    end

    context "with missing MBTI" do
      let(:user_b) do
        create_user_with_preference(
          { first_name: "Anon", mbti: nil },
          { schedule_availability: { "saturday" => %w[11:00 11:30] } }
        )
      end

      it "returns unknown" do
        expect(subject[:personality][:compatibility_label]).to eq("unknown")
      end
    end
  end

  describe "relationship goal breakdown" do
    it "detects aligned goals" do
      expect(subject[:relationship_goal][:user_goal]).to eq("serious")
      expect(subject[:relationship_goal][:match_goal]).to eq("serious")
      expect(subject[:relationship_goal][:alignment]).to eq("aligned")
    end

    context "with misaligned goals" do
      let(:user_b) do
        create_user_with_preference(
          { first_name: "Sarah", mbti: "INFP" },
          {
            relationship_goal: "casual",
            schedule_availability: { "saturday" => %w[11:00 11:30] }
          }
        )
      end

      it "returns misaligned" do
        expect(subject[:relationship_goal][:alignment]).to eq("misaligned")
      end
    end

    context "when one user is open_to_all" do
      let(:user_b) do
        create_user_with_preference(
          { first_name: "Sarah", mbti: "INFP" },
          {
            relationship_goal: "open_to_all",
            schedule_availability: { "saturday" => %w[11:00 11:30] }
          }
        )
      end

      it "returns partial" do
        expect(subject[:relationship_goal][:alignment]).to eq("partial")
      end
    end
  end

  describe "lifestyle breakdown" do
    it "counts aligned factors" do
      # alcohol: same (✓), smoking: same (✓), fitness: differ (✗), budget: adjacent (✓)
      expect(subject[:lifestyle][:alignment_score]).to eq(3)
    end

    it "marks each factor alignment" do
      factors = subject[:lifestyle][:factors]
      expect(factors[:alcohol][:aligned]).to be true
      expect(factors[:smoking][:aligned]).to be true
      expect(factors[:fitness][:aligned]).to be false
      expect(factors[:budget_level][:aligned]).to be true  # $$$ vs $$ = distance 1
    end

    context "with large budget gap" do
      let(:user_b) do
        create_user_with_preference(
          { first_name: "Sarah", mbti: "INFP" },
          {
            budget_level: "$",
            schedule_availability: { "saturday" => %w[11:00 11:30] }
          }
        )
      end

      it "marks budget as not aligned when distance > 1" do
        expect(subject[:lifestyle][:factors][:budget_level][:aligned]).to be false
      end
    end
  end

  describe "schedule breakdown" do
    it "computes overlap slots" do
      # Saturday overlap: 11:00, 11:30, 12:00 = 3 slots
      expect(subject[:schedule][:overlap_slots]).to eq(3)
    end

    it "computes overlap minutes" do
      expect(subject[:schedule][:overlap_minutes]).to eq(90)
    end

    it "computes overlap percentage" do
      # user_b has 8 total slots (5 sat + 3 tue), user_a has 11 (8 sat + 3 wed)
      # smaller = 8, overlap = 3, pct = 37.5 → 38 (rounded)
      expect(subject[:schedule][:overlap_percentage]).to eq(38)
    end

    it "identifies best days" do
      expect(subject[:schedule][:best_days]).to include("saturday")
    end

    context "with no schedule overlap" do
      let(:user_b) do
        create_user_with_preference(
          { first_name: "Sarah", mbti: "INFP" },
          {
            schedule_availability: { "monday" => %w[06:00 06:30] }
          }
        )
      end

      it "returns zero overlap" do
        expect(subject[:schedule][:overlap_slots]).to eq(0)
        expect(subject[:schedule][:overlap_minutes]).to eq(0)
        expect(subject[:schedule][:overlap_percentage]).to eq(0)
      end
    end
  end

  describe "shared interests placeholder" do
    it "returns empty interests array" do
      expect(subject[:shared_interests][:interests]).to eq([])
    end

    it "has nil commentary for LLM enrichment" do
      expect(subject[:shared_interests][:commentary]).to be_nil
    end
  end
end
