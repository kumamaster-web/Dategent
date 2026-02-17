class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :photo

  has_one :user_preference, dependent: :destroy
  has_one :agent, dependent: :destroy

  has_many :blocks_given, class_name: "Block", foreign_key: :blocker_user_id, dependent: :destroy
  has_many :blocks_received, class_name: "Block", foreign_key: :blocked_user_id, dependent: :destroy
  has_many :blocked_users, through: :blocks_given, source: :blocked_user
  has_many :blocked_by_users, through: :blocks_received, source: :blocker_user

  has_many :initiated_matches, through: :agent, source: :initiated_matches
  has_many :received_matches, through: :agent, source: :received_matches

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true
  validates :gender, inclusion: { in: %w[male female non_binary other] }, allow_nil: true
  validates :mbti, inclusion: {
    in: %w[INTJ INTP ENTJ ENTP INFJ INFP ENFJ ENFP ISTJ ISFJ ESTJ ESFJ ISTP ISFP ESTP ESFP]
  }, allow_nil: true
  validates :bio, length: { maximum: 500 }, allow_nil: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def age
    return nil unless date_of_birth
    now = Time.current.to_date
    now.year - date_of_birth.year - (now.yday < date_of_birth.yday ? 1 : 0)
  end

  def blocked?(other_user)
    blocks_given.exists?(blocked_user_id: other_user.id)
  end
end
