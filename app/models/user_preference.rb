class UserPreference < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :min_age, numericality: { greater_than_or_equal_to: 18 }, allow_nil: true
  validates :max_age, numericality: { greater_than_or_equal_to: 18 }, allow_nil: true
  validates :budget_level, inclusion: { in: %w[$ $$ $$$ $$$$] }, allow_nil: true
  validates :relationship_goal, inclusion: {
    in: %w[casual serious marriage friendship open_to_all]
  }, allow_nil: true
  validates :alcohol, inclusion: { in: %w[never sometimes often] }, allow_nil: true
  validates :smoking, inclusion: { in: %w[never sometimes often] }, allow_nil: true
  validates :fitness, inclusion: { in: %w[never sometimes active very_active] }, allow_nil: true

  def extras
    extras_json.present? ? JSON.parse(extras_json) : {}
  end

  def set_extra(key, value)
    data = extras
    data[key] = value
    update(extras_json: data.to_json)
  end
end
