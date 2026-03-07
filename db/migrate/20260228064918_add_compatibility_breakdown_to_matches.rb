class AddCompatibilityBreakdownToMatches < ActiveRecord::Migration[7.1]
  def change
    add_column :matches, :compatibility_breakdown, :jsonb, default: {}
  end
end
