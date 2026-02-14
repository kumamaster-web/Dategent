class CreateAgents < ActiveRecord::Migration[7.1]
  def change
    create_table :agents do |t|
      t.references :user, null: false, foreign_key: true
      t.text :personality_summary
      t.text :system_prompt
      t.string :status, default: "active"

      t.timestamps
    end
  end
end
