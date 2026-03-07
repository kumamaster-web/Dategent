class Venue < ApplicationRecord
  has_many :date_events, dependent: :nullify
  has_many :meetings, dependent: :destroy

  validates :name, presence: true
  # validates :price_tier, numericality: { in: 1..4 }
  # commented out because it was bugging during venues testing. discuss
  # later with Edward
end
