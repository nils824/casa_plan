class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :stays, dependent: :restrict_with_error
  has_many :decided_stays, class_name: "Stay", foreign_key: :decided_by_id,
                           inverse_of: :decided_by, dependent: :nullify

  enum :role, { member: "member", manager: "manager" }, default: :member, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
end