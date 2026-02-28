# frozen_string_literal: true

require "rails_helper"

RSpec.describe AgentContextBuilder, type: :service do
  let(:user) { create_full_user }
  let(:builder) { described_class.new(user) }

  describe "#system_prompt" do
    it "includes the agent name" do
      expect(builder.system_prompt).to include(user.agent.name)
    end

    it "includes the personality mode" do
      expect(builder.system_prompt).to include(user.agent.personality_mode)
    end

    it "includes the user's first name" do
      expect(builder.system_prompt).to include(user.first_name)
    end

    it "includes PII protection rules" do
      prompt = builder.system_prompt
      expect(prompt).to include("NEVER reveal")
      expect(prompt).to include("last name")
    end
  end

  describe "#profile_context" do
    it "includes the user's first name" do
      expect(builder.profile_context).to include(user.first_name)
    end

    it "includes the user's age" do
      expect(builder.profile_context).to include(user.age.to_s)
    end

    it "includes the user's MBTI" do
      expect(builder.profile_context).to include(user.mbti)
    end

    it "includes the user's city" do
      expect(builder.profile_context).to include(user.city)
    end

    it "includes the bio" do
      expect(builder.profile_context).to include(user.bio)
    end
  end

  describe "#preference_context" do
    it "includes preferred gender" do
      expect(builder.preference_context).to include(user.user_preference.preferred_gender)
    end

    it "includes age range" do
      pref = user.user_preference
      expect(builder.preference_context).to include("#{pref.min_age}-#{pref.max_age}")
    end

    it "includes relationship goal" do
      expect(builder.preference_context).to include(user.user_preference.relationship_goal)
    end

    it "includes venue types" do
      expect(builder.preference_context).to include("dinner")
    end
  end

  describe "#schedule_context" do
    it "includes availability days" do
      expect(builder.schedule_context).to include("Saturday")
    end

    it "returns fallback when schedule is empty" do
      user.user_preference.update!(schedule_availability: {})
      expect(builder.schedule_context).to include("Not yet configured")
    end
  end

  describe "#full_context" do
    it "combines profile, preference, and schedule contexts" do
      full = builder.full_context
      expect(full).to include(user.first_name)
      expect(full).to include(user.user_preference.preferred_gender)
      expect(full).to include("Saturday")
    end
  end
end
