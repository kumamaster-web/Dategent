# frozen_string_literal: true

require "rails_helper"

RSpec.describe VenueFinderService, type: :service do
  let!(:dinner_venue) do
    create_venue(name: "Tokyo Dinner", venue_type: "dinner", price_tier: 3, rating: 4.5)
  end
  let!(:cheap_dinner) do
    create_venue(name: "Budget Bites", venue_type: "dinner", price_tier: 1, rating: 4.0)
  end
  let!(:drinks_venue) do
    create_venue(name: "Cocktail Bar", venue_type: "drinks", price_tier: 3, rating: 4.7)
  end
  let!(:expensive_venue) do
    create_venue(name: "Luxury Place", venue_type: "dinner", price_tier: 4, rating: 4.9)
  end
  let!(:outdoor_venue) do
    create_venue(name: "Yoyogi Park", venue_type: "outdoor", price_tier: 1, rating: 4.5)
  end

  let(:user_a) do
    create_full_user(
      { first_name: "Alex" },
      { preferred_venue_types: %w[dinner drinks], budget_level: "$$$" }
    )
  end

  let(:user_b) do
    create_full_user(
      { first_name: "Sarah" },
      { preferred_venue_types: %w[dinner outdoor], budget_level: "$$" }
    )
  end

  subject(:service) { described_class.new(user_a, user_b) }

  describe "#call" do
    it "returns venues matching shared venue types" do
      results = service.call
      # shared type is "dinner", budget is min($$$ = 3, $$ = 2) = 2
      venue_types = results.map(&:venue_type).uniq
      expect(venue_types).to include("dinner")
    end

    it "respects the lower budget constraint" do
      results = service.call
      # $$ = tier 2, so only venues with price_tier <= 2
      results.each do |venue|
        expect(venue.price_tier).to be <= 2
      end
    end

    it "excludes venues above the budget" do
      results = service.call
      expect(results).not_to include(dinner_venue) # tier 3
      expect(results).not_to include(expensive_venue) # tier 4
    end

    it "includes affordable venues of overlapping types" do
      results = service.call
      expect(results).to include(cheap_dinner) # dinner, tier 1
    end

    it "orders by rating descending" do
      results = service.call.to_a
      next if results.size < 2

      ratings = results.map(&:rating)
      expect(ratings).to eq(ratings.sort.reverse)
    end

    it "limits results to 5" do
      # Create many more venues
      10.times do |i|
        create_venue(name: "Extra #{i}", venue_type: "dinner", price_tier: 1, rating: 3.0 + (i * 0.1))
      end

      results = service.call
      expect(results.size).to be <= 5
    end
  end

  context "when users have no overlapping venue types" do
    let(:user_a) do
      create_full_user(
        { first_name: "OnlyDrinks" },
        { preferred_venue_types: %w[drinks], budget_level: "$$$" }
      )
    end

    let(:user_b) do
      create_full_user(
        { first_name: "OnlyOutdoor" },
        { preferred_venue_types: %w[outdoor], budget_level: "$$$" }
      )
    end

    it "falls back to union of both types" do
      results = service.call
      venue_types = results.map(&:venue_type)
      # Should include both drinks and outdoor since no overlap
      expect(venue_types & %w[drinks outdoor]).not_to be_empty
    end
  end
end
