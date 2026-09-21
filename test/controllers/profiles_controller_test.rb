require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "guest is redirected to the login" do
    get profile_path
    assert_redirected_to new_session_path
  end

  test "user sees the own profile" do
    sign_in_as users(:anna)

    get profile_path

    assert_response :success
    assert_select "main", /anna@example.test/
  end

  test "user changes the name" do
    sign_in_as users(:anna)

    patch profile_path, params: { user: { name: "Anna Muster" } }

    assert_redirected_to profile_path
    assert_equal "Anna Muster", users(:anna).reload.name
  end
end
