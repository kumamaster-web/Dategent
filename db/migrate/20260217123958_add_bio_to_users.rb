class AddBioToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :bio, :text unless column_exists?(:users, :bio)
  end
end
