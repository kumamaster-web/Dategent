class CreateMatchesVenues < ActiveRecord::Migration[7.1]
  def change
    create_table :matches_venues do |t|
      t.references :match, null: false, foreign_key: true
      t.references :venue, null: false, foreign_key: true

      t.timestamps
    end
  end
end
