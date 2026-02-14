class CreateUserPreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :user_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.string :preferred_gender
      t.integer :min_age
      t.integer :max_age
      t.integer :max_distance
      t.string :preferred_education
      t.string :preferred_zodiac_sign
      t.string :preferred_mbti

      t.timestamps
    end
  end
end
