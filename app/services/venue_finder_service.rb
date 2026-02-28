# frozen_string_literal: true

# Finds venues that match both users' overlapping venue type preferences
# and budget constraints.
class VenueFinderService
  def initialize(user_a, user_b)
    @pref_a = user_a.user_preference
    @pref_b = user_b.user_preference
  end

  # Returns ActiveRecord::Relation of matching Venues, best-rated first
  def call
    types_a = @pref_a&.preferred_venue_types || []
    types_b = @pref_b&.preferred_venue_types || []
    shared_types = types_a & types_b
    shared_types = (types_a + types_b).uniq if shared_types.empty?

    return Venue.none if shared_types.empty?

    max_tier = [budget_to_tier(@pref_a&.budget_level), budget_to_tier(@pref_b&.budget_level)].min

    Venue.where(venue_type: shared_types)
         .where("price_tier <= ?", max_tier)
         .order(rating: :desc)
         .limit(5)
  end

  private

  def budget_to_tier(budget)
    case budget
    when "$"    then 1
    when "$$"   then 2
    when "$$$"  then 3
    when "$$$$" then 4
    else 3
    end
  end
end
