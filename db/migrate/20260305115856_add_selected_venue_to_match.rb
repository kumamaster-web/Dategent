class AddSelectedVenueToMatch < ActiveRecord::Migration[7.1]
  def change
    add_reference :matches, :selected_venue, null: true, foreign_key: { to_table: :venues }
  end
end
