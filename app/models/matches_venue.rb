class MatchesVenue < ApplicationRecord
  belongs_to :match
  belongs_to :venue
end
