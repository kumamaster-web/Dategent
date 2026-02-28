class CreateMatchTranscripts < ActiveRecord::Migration[7.1]
  def change
    create_table :match_transcripts do |t|
      t.references :match, null: false, foreign_key: true
      t.string :stage, null: false
      t.text :content, null: false

      t.timestamps
    end

    add_index :match_transcripts, [:match_id, :stage], unique: true
  end
end
