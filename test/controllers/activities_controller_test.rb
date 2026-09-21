require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  test "guest is redirected to the login" do
    get activities_path
    assert_redirected_to new_session_path
  end

  test "family member sees the activity feed" do
    stays(:ben_requested).confirm_by(users(:manager))
    sign_in_as users(:anna)

    get activities_path

    assert_response :success
    assert_select "div[id^='activity_']", /Verwalter/
  end
end
