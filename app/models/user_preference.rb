class UserPreference < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :min_age, numericality: { greater_than_or_equal_to: 18 }, allow_nil: true
  validates :max_age, numericality: { greater_than_or_equal_to: 18 }, allow_nil: true
  validates :budget_level, inclusion: { in: %w[$ $$ $$$ $$$$] }, allow_nil: true
  validates :relationship_goal, inclusion: {
    in: %w[casual serious marriage friendship open_to_all]
  }, allow_nil: true
  validates :alcohol, inclusion: { in: %w[never sometimes often] }, allow_nil: true
  validates :smoking, inclusion: { in: %w[never sometimes often] }, allow_nil: true
  validates :fitness, inclusion: { in: %w[never sometimes active very_active] }, allow_nil: true

  VENUE_TYPES = %w[coffee dinner drinks outdoor activity].freeze

  # All IANA timezone identifiers are valid via ActiveSupport
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone::MAPPING.values + ActiveSupport::TimeZone::MAPPING.keys },
            allow_nil: true, allow_blank: true

  validate :validate_venue_types
  validate :validate_schedule_format

  def venue_types
    preferred_venue_types || []
  end

  def schedule
    schedule_availability || {}
  end

  # Convert stored schedule to iCal-compatible availability blocks.
  # Returns array of hashes: { day:, start_time:, end_time:, timezone: }
  # Contiguous 30-min slots are merged into single blocks.
  def availability_blocks
    tz = timezone || "UTC"
    blocks = []
    %w[monday tuesday wednesday thursday friday saturday sunday].each do |day|
      slots = (schedule[day] || []).sort
      next if slots.empty?
      # Merge contiguous slots
      current_start = slots.first
      current_end = advance_30min(slots.first)
      slots[1..].each do |slot|
        if slot == current_end
          current_end = advance_30min(slot)
        else
          blocks << { day: day, start_time: current_start, end_time: current_end, timezone: tz }
          current_start = slot
          current_end = advance_30min(slot)
        end
      end
      blocks << { day: day, start_time: current_start, end_time: current_end, timezone: tz }
    end
    blocks
  end

  def extras
    extras_json.present? ? JSON.parse(extras_json) : {}
  end

  def set_extra(key, value)
    data = extras
    data[key] = value
    update(extras_json: data.to_json)
  end

  private

  def advance_30min(time_str)
    h, m = time_str.split(":").map(&:to_i)
    m += 30
    if m >= 60
      h += 1
      m -= 60
    end
    format("%02d:%02d", h, m)
  end

  def validate_venue_types
    return if preferred_venue_types.blank?
    invalid = Array(preferred_venue_types) - VENUE_TYPES
    errors.add(:preferred_venue_types, "contains invalid types: #{invalid.join(', ')}") if invalid.any?
  end

  def validate_schedule_format
    return if schedule_availability.blank?
    valid_days = %w[monday tuesday wednesday thursday friday saturday sunday]
    valid_slot_pattern = /\A\d{2}:\d{2}\z/

    schedule_availability.each do |day, slots|
      unless valid_days.include?(day.to_s)
        errors.add(:schedule_availability, "contains invalid day: #{day}")
        next
      end
      next unless slots.is_a?(Array)
      slots.each do |slot|
        unless slot.match?(valid_slot_pattern)
          errors.add(:schedule_availability, "contains invalid time format: #{slot}")
        end
      end
    end
  end
end
