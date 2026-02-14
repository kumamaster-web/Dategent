class Block < ApplicationRecord
  belongs_to :blocker_user, class_name: "User"
  belongs_to :blocked_user, class_name: "User"

  validates :blocker_user_id, uniqueness: { scope: :blocked_user_id }
  validate :cannot_block_self

  private

  def cannot_block_self
    errors.add(:blocked_user_id, "can't block yourself") if blocker_user_id == blocked_user_id
  end
end
