class Meeting < ApplicationRecord
  belongs_to :date_event
  belongs_to :venue
end
