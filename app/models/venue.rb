class Venue < ApplicationRecord
  has_many :date_events, dependent: :nullify
  has_many :meetings, dependent: :destroy

  validates :name, presence: true
  validates :price_tier, numericality: { in: 1..4 }
end
