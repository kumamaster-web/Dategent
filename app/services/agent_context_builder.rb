# frozen_string_literal: true

# Serializes a user's profile, preferences, and schedule into prompt context
# for their dating agent. Used by screening and negotiation jobs.
#
# Design: direct context injection (no RAG/embeddings needed yet —
# structured data is small per-user).
class AgentContextBuilder
  def initialize(user)
    @user = user
    @pref = user.user_preference
    @agent = user.agent
  end

  def system_prompt
    <<~PROMPT
      You are #{@agent.name}, a #{@agent.personality_mode} dating agent representing #{@user.first_name}.
      Your job is to find compatible matches and negotiate dates on behalf of your person.

      PERSONALITY MODE: #{@agent.personality_mode}
      - friendly: warm, encouraging, focuses on shared interests
      - professional: structured, data-driven, efficient
      - witty: playful banter, light humor, creative angles
      - caring: empathetic, prioritizes emotional safety
      - direct: no fluff, straight to compatibility facts

      RULES:
      - NEVER reveal your person's last name, exact address, workplace address, social media, or phone number
      - You may share: first name, general neighborhood/city, broad interests, lifestyle preferences
      - Be honest about dealbreakers — don't force incompatible matches
      - Respect your person's stated preferences as hard boundaries
      - You must advocate for your person's best interests
    PROMPT
  end

  def profile_context
    <<~CONTEXT
      YOUR PERSON'S PROFILE (private — do not share directly):
      - Name: #{@user.first_name} (age #{@user.age}, #{@user.gender}, #{@user.pronouns})
      - City: #{@user.city}, #{@user.country}
      - MBTI: #{@user.mbti} | Zodiac: #{@user.zodiac_sign}
      - Education: #{@user.education} | Occupation: #{@user.occupation}
      - Height: #{@user.height}cm
      - Bio: #{@user.bio}
    CONTEXT
  end

  def preference_context
    <<~CONTEXT
      YOUR PERSON'S PREFERENCES (use for screening — do not share raw data):
      - Looking for: #{@pref.preferred_gender}, ages #{@pref.min_age}-#{@pref.max_age}
      - Max distance: #{@pref.max_distance}km
      - Relationship goal: #{@pref.relationship_goal}
      - Budget level: #{@pref.budget_level}
      - Alcohol: #{@pref.alcohol} | Smoking: #{@pref.smoking} | Fitness: #{@pref.fitness}
      - Preferred venue types: #{@pref.preferred_venue_types&.join(', ')}
      - Timezone: #{@pref.timezone}
      #{extras_summary}
    CONTEXT
  end

  def schedule_context
    return "Schedule: Not yet configured." if @pref.schedule_availability.blank?

    lines = @pref.schedule_availability.map do |day, slots|
      "- #{day.capitalize}: #{slots.first}–#{slots.last} (#{slots.size * 30} min available)"
    end

    "AVAILABILITY (private — share only overlap results):\n#{lines.join("\n")}"
  end

  def full_context
    [profile_context, preference_context, schedule_context].join("\n")
  end

  private

  def extras_summary
    return "" if @pref.extras_json.blank?

    parsed = @pref.extras
    return "" if parsed.empty?

    pairs = parsed.map { |k, v| "#{k}: #{v}" }.join(", ")
    "- Additional preferences: #{pairs}"
  end
end
