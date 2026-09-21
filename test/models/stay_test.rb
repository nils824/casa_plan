require "test_helper"

class StayTest < ActiveSupport::TestCase
  setup do
    @house = houses(:casa)
    @manager = users(:manager)
  end

  def build_stay(arrival_in, departure_in, user: users(:ben), guests: 2)
    @house.stays.new(user: user, guests_count: guests,
                     arrival_on: Date.current + arrival_in, departure_on: Date.current + departure_in)
  end

  # Fachregel: bestätigte Aufenthalte dürfen sich nicht überschneiden

  test "request overlapping a confirmed stay is invalid and names the conflict" do
    stay = build_stay(18, 25)

    assert_not stay.valid?
    assert_match "Überschneidung mit dem bestätigten Aufenthalt von Anna", stay.errors[:base].first
  end

  test "arrival on the departure day of a confirmed stay is allowed" do
    assert build_stay(21, 24).valid?
  end

  test "departure on the arrival day of a confirmed stay is allowed" do
    assert build_stay(10, 14).valid?
  end

  test "overlapping an open request is allowed, the manager decides" do
    assert build_stay(31, 33, user: users(:anna)).valid?
  end

  # Weitere Validierungen

  test "more guests than beds is invalid" do
    stay = build_stay(40, 42, guests: 7)

    assert_not stay.valid?
    assert_includes stay.errors[:guests_count], "übersteigt die Bettenanzahl (6)"
  end

  test "departure before arrival is invalid" do
    stay = build_stay(45, 43)

    assert_not stay.valid?
    assert_includes stay.errors[:departure_on], "muss nach der Anreise liegen"
  end

  test "arrival in the past is invalid" do
    stay = build_stay(-2, 3)

    assert_not stay.valid?
    assert_includes stay.errors[:arrival_on], "darf nicht in der Vergangenheit liegen"
  end

  # Bestätigen, Ablehnen, Zurückziehen

  test "manager confirms a request and an activity is recorded" do
    stay = stays(:ben_requested)

    assert_difference -> { Activity.count }, 1 do
      assert stay.confirm_by(@manager)
    end

    stay.reload
    assert stay.confirmed?
    assert_equal @manager, stay.decided_by
    assert_equal "confirmed", stay.activities.last.event
  end

  test "second of two overlapping requests cannot be confirmed" do
    first = stays(:ben_requested)
    # Loaded before the first confirmation, like in a second browser window.
    second = Stay.find(stays(:anna_overlapping_request).id)

    assert first.confirm_by(@manager)

    assert_no_difference -> { Activity.count } do
      assert_not second.confirm_by(@manager)
    end
    assert_match "Überschneidung", second.errors[:base].join
    assert second.reload.requested?
  end

  test "a decided stay cannot be changed anymore" do
    stay = stays(:anna_confirmed)
    stay.guests_count = 2

    assert_not stay.save
    assert_match "bereits «Bestätigt»", stay.errors[:base].join
  end

  test "rejecting requires a reason" do
    stay = stays(:ben_requested)

    assert_not stay.reject_by(@manager, "")
    assert stay.errors[:rejection_reason].any?
    assert stay.reload.requested?
  end

  test "owner withdraws a request" do
    stay = stays(:ben_requested)

    assert stay.withdraw_by(users(:ben))
    assert stay.reload.withdrawn?
    assert_equal "withdrawn", stay.activities.last.event
  end

  # Transaktion und Locking

  test "stay and activity are saved together or not at all" do
    stay = build_stay(40, 42, user: users(:anna))

    assert_no_difference -> { Stay.count } do
      # An invalid activity makes the transaction roll back the stay as well.
      assert_not stay.save_with_activity(actor: users(:anna), event: "unknown")
    end
  end

  test "an outdated version cannot overwrite a newer change" do
    first = Stay.find(stays(:ben_requested).id)
    second = Stay.find(stays(:ben_requested).id)

    first.update!(guests_count: 3)
    second.guests_count = 1

    assert_raises(ActiveRecord::StaleObjectError) { second.save }
  end
end
