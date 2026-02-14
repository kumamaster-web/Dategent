class CreateBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :blocks do |t|
      t.references :blocker_user, null: false, foreign_key: { to_table: :users }
      t.references :blocked_user, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :blocks, [:blocker_user_id, :blocked_user_id], unique: true
  end
end
