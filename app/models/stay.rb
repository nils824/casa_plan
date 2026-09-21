class Stay < ApplicationRecord
  belongs_to :house
  belongs_to :user
  belongs_to :decided_by, class_name: "User", optional: true
  has_many :activities, dependent: :destroy

  enum :status, {
    requested: "requested",
    confirmed: "confirmed",
    rejected: "rejected",
    withdrawn: "withdrawn"
  }, default: :requested, validate: true

  # Two stays overlap if they share at least one night.
  # Departure and arrival on the same day is allowed (strict comparison).
  scope :overlapping, ->(arrival_on, departure_on) {
    where("arrival_on < ? AND departure_on > ?", departure_on, arrival_on)
  }
  scope :upcoming, -> { where("departure_on >= ?", Date.current) }
  scope :active, -> { where(status: %w[requested confirmed]) }

  validates :arrival_on, :departure_on, presence: true
  validates :guests_count, numericality: { only_integer: true, greater_than: 0 }
  validates :rejection_reason, presence: true, if: :rejected?
  validates :decided_by, :decided_at, presence: true, if: -> { confirmed? || rejected? }
  validate :departure_after_arrival
  validate :arrival_not_in_past, if: :will_save_change_to_arrival_on?
  validate :guests_within_beds
  validate :no_overlap_with_confirmed_stays, if: -> { requested? || confirmed? }
  validate :only_open_requests_changeable, on: :update

  def conflicting_stays
    house.stays.confirmed.overlapping(arrival_on, departure_on).where.not(id: id)
  end

  def nights
    (departure_on - arrival_on).to_i
  end

  def owned_by?(other_user)
    other_user.present? && user_id == other_user.id
  end

  def period_label
    "#{I18n.l(arrival_on)} – #{I18n.l(departure_on)}"
  end

  def summary_text
    "#{period_label}, #{guests_count} #{guests_count == 1 ? 'Person' : 'Personen'}"
  end

  def status_label
    I18n.t(status, scope: "stay_statuses")
  end

  # Saves the stay and records an activity. Both are stored together or not at all.
  def save_with_activity(actor:, event:)
    self.class.transaction do
      save!
      activities.create!(user: actor, event: event, summary: summary_text)
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def confirm_by(manager)
    transition_to(:confirmed, actor: manager, decided_by: manager, decided_at: Time.current)
  end

  def reject_by(manager, reason)
    transition_to(:rejected, actor: manager, decided_by: manager, decided_at: Time.current,
                             rejection_reason: reason)
  end

  def withdraw_by(actor)
    transition_to(:withdrawn, actor: actor)
  end

  private

  # Changes the status inside a transaction. With SQLite, Rails starts the
  # transaction with BEGIN IMMEDIATE, so only one connection can write at a time.
  # The stay is reloaded *inside* the transaction: a second, concurrent decision
  # waits for the first one and then sees its result (e.g. an overlapping stay
  # that was just confirmed), so the overlap validation cannot be bypassed.
  def transition_to(new_status, actor:, **attributes)
    self.class.transaction do
      reload
      assign_attributes(status: new_status, **attributes)
      save!
      activities.create!(user: actor, event: new_status.to_s, summary: summary_text)
    end
    true
  rescue ActiveRecord::RecordInvalid
    restore_attributes(%w[status decided_by_id decided_at])
    false
  end

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
                      "(#{conflict.period_label})")
  end

  def only_open_requests_changeable
    return if status_in_database == "requested"

    current_label = I18n.t(status_in_database, scope: "stay_statuses")
    errors.add(:base, "Diese Anfrage ist bereits «#{current_label}» und kann nicht mehr geändert werden.")
  end
end
