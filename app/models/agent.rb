class Agent < ApplicationRecord
  belongs_to :user

  has_many :initiated_matches, class_name: "Match", foreign_key: :initiator_agent_id, dependent: :destroy
  has_many :received_matches, class_name: "Match", foreign_key: :receiver_agent_id, dependent: :destroy

  validates :user_id, uniqueness: true
  validates :match_cap_per_week, numericality: { in: 1..10 }

  def all_matches
    Match.where("initiator_agent_id = ? OR receiver_agent_id = ?", id, id)
  end
end
