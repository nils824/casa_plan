class Stay < ApplicationRecord
  belongs_to :house
  belongs_to :user
  belongs_to :decided_by
end
