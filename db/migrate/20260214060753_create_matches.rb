class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.references :initiator_agent, null: false, foreign_key: { to_table: :agents }
      t.references :receiver_agent, null: false, foreign_key: { to_table: :agents }
      t.decimal :compatibility_score
      t.string :status
      t.text :chat_transcript
      t.timestamps
    end
  end
end
