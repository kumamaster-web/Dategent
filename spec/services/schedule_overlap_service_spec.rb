# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScheduleOverlapService, type: :service do
  let(:user_a) do
    create_full_user(
      { first_name: "Alex" },
      {
        schedule_availability: {
          "monday" => %w[19:00 19:30 20:00 20:30],
          "friday" => %w[18:00 18:30 19:00 19:30 20:00],
          "saturday" => %w[11:00 11:30 12:00 18:00 18:30 19:00]
        }
      }
    )
  end

  let(:user_b) do
    create_full_user(
      { first_name: "Sarah" },
      {
        schedule_availability: {
          "friday" => %w[19:00 19:30 20:00 20:30],
          "saturday" => %w[10:00 10:30 11:00 18:00 18:30 19:00 19:30]
        }
      }
    )
  end

  subject(:service) { described_class.new(user_a, user_b) }

  describe "#call" do
    it "returns overlapping slots for shared days" do
      result = service.call
      expect(result).to have_key("friday")
      expect(result).to have_key("saturday")
    end

    it "does not include days with no overlap" do
      result = service.call
      expect(result).not_to have_key("monday")
    end

    it "finds correct friday overlap" do
      result = service.call
      expect(result["friday"]).to eq(%w[19:00 19:30 20:00])
    end

    it "finds correct saturday overlap" do
      result = service.call
      expect(result["saturday"]).to include("18:00", "18:30", "19:00")
    end

    it "sorts overlapping slots" do
      result = service.call
      result.each_value do |slots|
        expect(slots).to eq(slots.sort)
      end
    end
  end

  describe "#total_overlap_minutes" do
    it "returns the total overlapping minutes" do
      minutes = service.total_overlap_minutes
      # friday: 3 slots * 30 = 90
      # saturday: at least 3 slots * 30 = 90 (11:00 + 18:00, 18:30, 19:00)
      expect(minutes).to be > 0
      expect(minutes).to be_a(Integer)
    end
  end

  describe "#sufficient_overlap?" do
    it "returns true when there is sufficient overlap" do
      expect(service.sufficient_overlap?(min_slots: 2)).to be true
    end

    it "returns false when overlap is insufficient" do
      expect(service.sufficient_overlap?(min_slots: 100)).to be false
    end
  end

  context "when one user has no schedule" do
    let(:user_b) do
      create_full_user(
        { first_name: "NoSchedule" },
        { schedule_availability: {} }
      )
    end

    it "returns an empty hash" do
      expect(service.call).to eq({})
    end

    it "reports zero minutes" do
      expect(service.total_overlap_minutes).to eq(0)
    end
  end
end
