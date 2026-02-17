class AddTimezoneToUserPreferences < ActiveRecord::Migration[7.1]
  def change
    add_column :user_preferences, :timezone, :string, default: "UTC"
  end
end
