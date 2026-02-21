# frozen_string_literal: true

# Computes the intersection of two users' weekly availability schedules.
# Returns a hash of day → overlapping 30-min slots.
#
# Example output:
#   { "saturday" => ["18:00", "18:30", "19:00"], "friday" => ["19:00", "19:30"] }
class ScheduleOverlapService
  def initialize(user_a, user_b)
    @sched_a = user_a.user_preference&.schedule_availability || {}
    @sched_b = user_b.user_preference&.schedule_availability || {}
  end

  # Returns Hash of day => Array of overlapping time slots
  def call
    overlapping = {}

    @sched_a.each do |day, slots_a|
      next unless @sched_b[day]

      common = Array(slots_a) & Array(@sched_b[day])
      overlapping[day] = common.sort if common.any?
    end

    overlapping
  end

  # Returns total overlapping minutes across the week
  def total_overlap_minutes
    call.values.sum { |slots| slots.size * 30 }
  end

  # Returns true if there's at least min_slots overlapping slots
  def sufficient_overlap?(min_slots: 2)
    call.values.sum(&:size) >= min_slots
  end
end
