class Review < ApplicationRecord
  belongs_to :reviewer, class_name: "User"
  belongs_to :reviewee, class_name: "User"

  VALID_RATINGS = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0].freeze
  validates :rating, presence: true, inclusion: { in: VALID_RATINGS }
  validates :content, presence: true, length: { minimum: 10, maximum: 200,
                                              too_short: "At least 10 words", too_long:"No longer than 200 words." }
end
