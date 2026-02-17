class Agent < ApplicationRecord
  belongs_to :user

  has_many :initiated_matches, class_name: "Match", foreign_key: :initiator_agent_id, dependent: :destroy
  has_many :received_matches, class_name: "Match", foreign_key: :receiver_agent_id, dependent: :destroy

  validates :user_id, uniqueness: true
  validates :match_cap_per_week, numericality: { in: 1..10 }
  validates :personality_mode, inclusion: {
    in: %w[friendly professional witty caring direct]
  }, allow_nil: true

  AGGRESSIVENESS_LEVELS = {
    "conservative" => 1..2,
    "moderate" => 3..5,
    "active" => 6..10
  }.freeze

  def aggressiveness_level
    AGGRESSIVENESS_LEVELS.find { |_, range| range.cover?(match_cap_per_week) }&.first || "moderate"
  end

  def aggressiveness_level=(level)
    self.match_cap_per_week = case level
    when "conservative" then 2
    when "moderate" then 5
    when "active" then 8
    else 5
    end
  end

  def all_matches
    Match.where("initiator_agent_id = ? OR receiver_agent_id = ?", id, id)
  end
end
