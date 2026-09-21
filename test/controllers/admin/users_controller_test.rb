require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "member cannot open the user management" do
    sign_in_as users(:anna)

    get admin_users_path

    assert_redirected_to root_path
  end

  test "member cannot change a role with a direct request" do
    sign_in_as users(:anna)

    patch admin_user_path(users(:anna)), params: { user: { role: "manager" } }

    assert users(:anna).reload.member?
  end

  test "manager sees all users" do
    sign_in_as users(:manager)

    get admin_users_path

    assert_response :success
    assert_select "tr[id^='user_']", User.count
  end

  test "manager changes the role of another user" do
    sign_in_as users(:manager)

    patch admin_user_path(users(:ben)), params: { user: { name: "Ben", email_address: "ben@example.test", role: "manager" } }

    assert_redirected_to admin_users_path
    assert users(:ben).reload.manager?
  end

  test "manager cannot change the own role" do
    sign_in_as users(:manager)

    patch admin_user_path(users(:manager)), params: { user: { name: "Verwalter", role: "member" } }

    assert users(:manager).reload.manager?
  end
end
