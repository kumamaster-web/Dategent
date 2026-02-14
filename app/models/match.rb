class Match < ApplicationRecord
  belongs_to :initiator_agent, class_name: "Agent"
  belongs_to :receiver_agent, class_name: "Agent"

  has_many :date_events, dependent: :destroy

  validates :status, inclusion: {
    in: %w[screening evaluating date_proposed confirmed declined]
  }

  def initiator_user
    initiator_agent.user
  end

  def receiver_user
    receiver_agent.user
  end
end
