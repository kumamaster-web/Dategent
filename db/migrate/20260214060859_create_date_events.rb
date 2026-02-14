class CreateDateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :date_events do |t|
      t.references :match, null: false, foreign_key: true
      t.references :venue, null: false, foreign_key: true
      t.datetime :scheduled_time
      t.string :booking_status
      t.integer :rating_score

      t.timestamps
    end
  end
end
