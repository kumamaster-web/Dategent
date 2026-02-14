class DateEvent < ApplicationRecord
  belongs_to :match
  belongs_to :venue, optional: true

  has_one :meeting, dependent: :destroy

  validates :booking_status, inclusion: {
    in: %w[proposed accepted declined cancelled]
  }, allow_nil: true
  validates :rating_score, numericality: { in: 1..5 }, allow_nil: true
end
