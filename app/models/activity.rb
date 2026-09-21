class Activity < ApplicationRecord
  EVENTS = %w[requested updated withdrawn confirmed rejected].freeze

  belongs_to :user
  belongs_to :stay

  validates :event, inclusion: { in: EVENTS }
  validates :summary, presence: true

  def description
    I18n.t(event, scope: "activity_events")
  end
end
