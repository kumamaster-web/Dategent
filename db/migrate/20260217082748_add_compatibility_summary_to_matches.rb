class AddCompatibilitySummaryToMatches < ActiveRecord::Migration[7.1]
  def change
    add_column :matches, :compatibility_summary, :text
  end
end
