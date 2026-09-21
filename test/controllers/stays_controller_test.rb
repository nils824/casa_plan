require "test_helper"

class StaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ben_request = stays(:ben_requested)
  end

  def stay_params(arrival_in, departure_in, guests: 2, note: nil)
    { stay: { arrival_on: Date.current + arrival_in, departure_on: Date.current + departure_in,
              guests_count: guests, note: note } }
  end

  # Zugriff

  test "guest is redirected to the login" do
    get stays_path
    assert_redirected_to new_session_path
  end

  test "family member sees the occupancy plan" do
    sign_in_as users(:ben)

    get stays_path

    assert_response :success
    assert_select "#plan", /Anna/
    assert_select "#open_requests", count: 0
  end

  test "manager sees open requests" do
    sign_in_as users(:manager)

    get stays_path

    assert_select "#open_requests", /Ben/
  end

  # Kernablauf: anfragen

  test "member requests a stay" do
    sign_in_as users(:anna)

    assert_difference [ "Stay.count", "Activity.count" ], 1 do
      post stays_path, params: stay_params(40, 44)
    end

    stay = Stay.order(:id).last
    assert_redirected_to stay_path(stay)
    assert stay.requested?
    assert_equal users(:anna), stay.user
  end

  test "overlapping request is refused and the input is kept" do
    sign_in_as users(:ben)

    assert_no_difference "Stay.count" do
      post stays_path, params: stay_params(18, 25, note: "Herbstferien")
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Überschneidung mit dem bestätigten Aufenthalt von Anna/
    assert_select "input[name='stay[arrival_on]'][value=?]", (Date.current + 18).to_s
    assert_select "textarea[name='stay[note]']", /Herbstferien/
  end

  # Kernablauf: bestätigen

  test "manager confirms a request" do
    sign_in_as users(:manager)

    patch confirm_stay_path(@ben_request)

    assert_redirected_to stay_path(@ben_request)
    assert @ben_request.reload.confirmed?
  end

  test "manager cannot confirm a request that overlaps a confirmed stay" do
    @ben_request.confirm_by(users(:manager))
    sign_in_as users(:manager)

    patch confirm_stay_path(stays(:anna_overlapping_request))

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Überschneidung mit dem bestätigten Aufenthalt von Ben/
    assert stays(:anna_overlapping_request).reload.requested?
  end

  test "member cannot confirm with a direct request" do
    sign_in_as users(:ben)

    patch confirm_stay_path(@ben_request)

    assert_redirected_to root_path
    assert @ben_request.reload.requested?
    follow_redirect!
    assert_select "#flash", /Nur der Verwalter kann Anfragen bestätigen/
  end

  test "manager rejects a request with a reason" do
    sign_in_as users(:manager)

    patch reject_stay_path(@ben_request), params: { stay: { rejection_reason: "Haus wird renoviert" } }

    assert_redirected_to stay_path(@ben_request)
    assert @ben_request.reload.rejected?
    assert_equal "Haus wird renoviert", @ben_request.rejection_reason
  end

  # Bearbeiten und zurückziehen

  test "member updates own open request" do
    sign_in_as users(:ben)

    patch stay_path(@ben_request), params: { stay: { guests_count: 3, lock_version: @ben_request.lock_version } }

    assert_redirected_to stay_path(@ben_request)
    assert_equal 3, @ben_request.reload.guests_count
  end

  test "member cannot update another member's request with a direct request" do
    sign_in_as users(:anna)

    patch stay_path(@ben_request), params: { stay: { guests_count: 5, lock_version: @ben_request.lock_version } }

    assert_redirected_to root_path
    assert_equal 2, @ben_request.reload.guests_count
  end

  test "outdated form shows a conflict and keeps the input" do
    old_version = @ben_request.lock_version
    @ben_request.update!(guests_count: 3) # someone else saved in the meantime
    sign_in_as users(:ben)

    patch stay_path(@ben_request), params: { stay: { guests_count: 1, note: "Neue Bemerkung", lock_version: old_version } }

    assert_response :conflict
    assert_select "#error_explanation", /inzwischen von jemand anderem geändert/
    assert_select "textarea[name='stay[note]']", /Neue Bemerkung/
    assert_equal 3, @ben_request.reload.guests_count
  end

  test "a decided stay cannot be edited" do
    sign_in_as users(:anna)

    get edit_stay_path(stays(:anna_confirmed))

    assert_redirected_to root_path
  end

  test "member withdraws own request" do
    sign_in_as users(:ben)

    assert_difference "Activity.count", 1 do
      patch withdraw_stay_path(@ben_request)
    end

    assert @ben_request.reload.withdrawn?
  end
end
