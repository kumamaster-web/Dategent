class AddVenueAndScheduleToUserPreferences < ActiveRecord::Migration[7.1]
  def change
    add_column :user_preferences, :preferred_venue_types, :jsonb, default: []
    add_column :user_preferences, :schedule_availability, :jsonb, default: {}
  end
end
