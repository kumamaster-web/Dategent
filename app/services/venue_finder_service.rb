# frozen_string_literal: true

# Finds venues that match both users' overlapping venue type preferences
# and budget constraints.
class VenueFinderService
  def initialize(user_a, user_b, match)
    # @pref_a = user_a.user_preference
    # @pref_b = user_b.user_preference

    @match = match # pulled this from the negotiation_job in order to call in other
                    # methods
    @user1_venues = @match.initiator_agent.user.user_preference.preferred_venue_types
    @user2_venues = @match.receiver_agent.user.user_preference.preferred_venue_types
    @user1_city = @match.initiator_agent.user.city
    @user2_city = @match.receiver_agent.user.city
    @user1_country = @match.initiator_agent.user.country
    @user2_country = @match.receiver_agent.user.country
    @user1_max_dist = @match.initiator_agent.user.user_preference.max_distance
    @user2_max_dist = @match.receiver_agent.user.user_preference.max_distance
  end

  # Returns ActiveRecord::Relation of matching Venues, best-rated first
  def call
    @venue_prompt = "
      You are a Venue analyzer.

      I am person who is matching with another person, and we need a list of five
      venues that are created based on our preferences.

      These venues should be searched through Google Maps. Do not just pick venues
      that are in one of the user one's location: #{@user1_city + "," + @user1_country}
      and user two's location: #{@user2_city + "," + @user2_country}.
      You can pick some halfway too.

      The venues should be based by considering user one's preferences: #{@user1_venues}
      and user two's preferences: #{@user2_venues}. Prioritize the ones that are mutual.
      Also consider user one's max distance: #{@user1_max_dist} and user two's
      max distance: #{@user2_max_dist}

      Please show five recommended venues by JSON format with the this information:
      name, address, and Google Map URL. Show this with no previous texts. Just
      give me the JSON format as described above.
    "


    @chat = RubyLLM.chat
    @response = @chat.ask(@venue_prompt)

    @trimmed_response = @response.content.delete("`").gsub("json", "")
    @parsed_response = JSON.parse @trimmed_response


    @parsed_response.each do |venue|
      new_venue = Venue.new # create a new empty Active Record object

      new_venue.name = venue["name"] # Hash access then set to ActiveRecord
      new_venue.address = venue["address"]
      new_venue.google_map_url = venue["Google Map URL"]
      # new_venue.save unless Venue.exists?(name: new_venue.name, address: new_venue.address)
      new_venue = Venue.find_or_create_by!(name: new_venue.name, address: new_venue.address)
      # if the venue exists, we need to find it's ID
      # if it does not exist, we need to save it

      # doing the unless thingy is to avoid duplicates

      new_matchesvenue = MatchesVenue.new

      new_matchesvenue.match_id = @match.id
      new_matchesvenue.venue_id = new_venue.id
      new_matchesvenue.save!
    end

    # types_a = @pref_a&.preferred_venue_types || []
    # types_b = @pref_b&.preferred_venue_types || []
    # shared_types = types_a & types_b
    # shared_types = (types_a + types_b).uniq if shared_types.empty?

    # return Venue.none if shared_types.empty?

    # max_tier = [budget_to_tier(@pref_a&.budget_level), budget_to_tier(@pref_b&.budget_level)].min

    # Venue.where(venue_type: shared_types)
    #      .where("price_tier <= ?", max_tier)
    #      .order(rating: :desc)
    #      .limit(5)
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
