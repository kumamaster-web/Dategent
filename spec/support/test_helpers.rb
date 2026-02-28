# frozen_string_literal: true

# Shared test helpers for creating domain objects.
# Avoids FactoryBot dependency — uses plain Ruby methods.
module TestHelpers
  module_function

  def create_user(overrides = {})
    defaults = {
      first_name: "Test",
      last_name: "User",
      email: "test-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123",
      gender: "male",
      city: "Tokyo",
      country: "Japan",
      date_of_birth: Date.new(1994, 6, 15),
      height: 175,
      pronouns: "he/him",
      mbti: "ENFJ",
      zodiac_sign: "Gemini",
      education: "Bachelor's",
      occupation: "Engineer",
      language: "EN",
      bio: "Test bio"
    }
    User.create!(defaults.merge(overrides))
  end

  def create_user_with_preference(user_overrides = {}, pref_overrides = {})
    user = create_user(user_overrides)
    pref_defaults = {
      preferred_gender: "female",
      min_age: 24,
      max_age: 35,
      max_distance: 25,
      budget_level: "$$$",
      relationship_goal: "serious",
      alcohol: "sometimes",
      smoking: "never",
      fitness: "active",
      preferred_venue_types: %w[dinner drinks outdoor],
      timezone: "Asia/Tokyo",
      schedule_availability: {
        "saturday" => %w[18:00 18:30 19:00 19:30 20:00],
        "friday" => %w[19:00 19:30 20:00]
      }
    }
    UserPreference.create!(pref_defaults.merge(pref_overrides).merge(user: user))
    user.reload
  end

  def create_agent(user, overrides = {})
    defaults = {
      user: user,
      name: "#{user.first_name}'s Agent",
      personality_mode: "friendly",
      match_cap_per_week: 5,
      autopilot: true,
      status: "active"
    }
    Agent.create!(defaults.merge(overrides))
  end

  def create_full_user(user_overrides = {}, pref_overrides = {}, agent_overrides = {})
    user = create_user_with_preference(user_overrides, pref_overrides)
    create_agent(user, agent_overrides)
    user.reload
  end

  def create_venue(overrides = {})
    defaults = {
      name: "Test Venue #{SecureRandom.hex(3)}",
      address: "1-1-1 Shibuya, Shibuya-ku",
      city: "Tokyo",
      venue_type: "dinner",
      latitude: 35.6580,
      longitude: 139.7016,
      rating: 4.5,
      price_tier: 2
    }
    Venue.create!(defaults.merge(overrides))
  end

  def create_match(initiator_agent, receiver_agent, overrides = {})
    defaults = {
      initiator_agent: initiator_agent,
      receiver_agent: receiver_agent,
      status: "screening",
      compatibility_score: 0.0
    }
    Match.create!(defaults.merge(overrides))
  end
end
