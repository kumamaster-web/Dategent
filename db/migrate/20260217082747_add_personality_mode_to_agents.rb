class AddPersonalityModeToAgents < ActiveRecord::Migration[7.1]
  def change
    add_column :agents, :personality_mode, :string, default: "friendly"
  end
end
