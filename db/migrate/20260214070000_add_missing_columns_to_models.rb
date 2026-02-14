class AddMissingColumnsToModels < ActiveRecord::Migration[7.1]
  def change
    # Agents
    add_column :agents, :match_cap_per_week, :integer, default: 5

    # User Preferences
    add_column :user_preferences, :budget_level, :string
    add_column :user_preferences, :relationship_goal, :string
    add_column :user_preferences, :alcohol, :string
    add_column :user_preferences, :smoking, :string
    add_column :user_preferences, :fitness, :string
    add_column :user_preferences, :extras_json, :text

    # Venues
    add_column :venues, :price_tier, :integer

    # Date Events - make venue optional
    change_column_null :date_events, :venue_id, true
  end
end
