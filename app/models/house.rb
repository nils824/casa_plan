class House < ApplicationRecord
  has_many :stays, dependent: :restrict_with_error

  validates :name, presence: true
  validates :beds, numericality: { only_integer: true, greater_than: 0 }
end