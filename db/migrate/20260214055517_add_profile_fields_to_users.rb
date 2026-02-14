class AddProfileFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.boolean :is_verified
      t.string :first_name
      t.string :last_name
      t.string :city
      t.string :country
      t.string :pronouns
      t.integer :height
      t.date :date_of_birth
      t.string :language
      t.string :zodiac_sign
      t.string :education
      t.string :occupation
      t.string :mbti
    end
  end
end
