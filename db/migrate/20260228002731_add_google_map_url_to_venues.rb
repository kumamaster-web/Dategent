class AddGoogleMapUrlToVenues < ActiveRecord::Migration[7.1]
  def change
    add_column :venues, :google_map_url, :string
  end
end
