class Stay < ApplicationRecord
  belongs_to :house
  belongs_to :user
  belongs_to :decided_by, class_name: "User", optional: true

  enum :status, {
    requested: "requested",
    confirmed: "confirmed",
    rejected: "rejected",
    withdrawn: "withdrawn"
  }, default: :requested, validate: true

  scope :overlapping, ->(arrival_on, departure_on) {
    where("arrival_on < ? AND departure_on > ?", departure_on, arrival_on)
  }

  validates :arrival_on, :departure_on, presence: true
  validates :guests_count, numericality: { only_integer: true, greater_than: 0 }
  validates :rejection_reason, presence: true, if: :rejected?
  validates :decided_by, :decided_at, presence: true, if: -> { confirmed? || rejected? }
  validate :departure_after_arrival
  validate :arrival_not_in_past, on: :create
  validate :guests_within_beds
  validate :no_overlap_with_confirmed_stays, if: -> { requested? || confirmed? }

  def conflicting_stays
    house.stays.confirmed.overlapping(arrival_on, departure_on).where.not(id: id)
  end

  def nights
    (departure_on - arrival_on).to_i
  end

  private

  def departure_after_arrival
    return if arrival_on.blank? || departure_on.blank?

    errors.add(:departure_on, "muss nach der Anreise liegen") if departure_on <= arrival_on
  end

  def arrival_not_in_past
    return if arrival_on.blank?

    errors.add(:arrival_on, "darf nicht in der Vergangenheit liegen") if arrival_on < Date.current
  end

  def guests_within_beds
    return if house.nil? || guests_count.blank?

    errors.add(:guests_count, "übersteigt die Bettenanzahl (#{house.beds})") if guests_count > house.beds
  end

  def no_overlap_with_confirmed_stays
    return if house.nil? || arrival_on.blank? || departure_on.blank? || departure_on <= arrival_on

    conflict = conflicting_stays.first
    return unless conflict

    errors.add(:base, "Überschneidung mit dem bestätigten Aufenthalt von #{conflict.user.name} " \
                      "(#{conflict.arrival_on.strftime('%d.%m.%Y')} – #{conflict.departure_on.strftime('%d.%m.%Y')})")
  end
end
