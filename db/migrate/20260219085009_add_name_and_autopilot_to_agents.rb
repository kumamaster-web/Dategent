class AddNameAndAutopilotToAgents < ActiveRecord::Migration[7.1]
  def change
    add_column :agents, :name, :string unless column_exists?(:agents, :name)
    add_column :agents, :autopilot, :boolean, default: false unless column_exists?(:agents, :autopilot)
  end
end
