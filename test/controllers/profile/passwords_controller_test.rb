require "test_helper"

class Profile::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:anna) }

  test "wrong current password is refused" do
    sign_in_as @user

    assert_no_changes -> { @user.reload.password_digest } do
      patch profile_password_path, params: { user: { password_challenge: "falsches-passwort",
                                                     password: "neues-passwort-1", password_confirmation: "neues-passwort-1" } }
    end

    assert_response :unprocessable_entity
  end

  test "missing current password is refused" do
    sign_in_as @user

    assert_no_changes -> { @user.reload.password_digest } do
      patch profile_password_path, params: { user: { password: "neues-passwort-1", password_confirmation: "neues-passwort-1" } }
    end
  end

  test "password change ends all other sessions" do
    other_session = @user.sessions.create!
    sign_in_as @user

    patch profile_password_path, params: { user: { password_challenge: "casaplan-demo",
                                                   password: "neues-passwort-1", password_confirmation: "neues-passwort-1" } }

    assert_redirected_to profile_path
    assert @user.reload.authenticate("neues-passwort-1")
    assert_not Session.exists?(other_session.id)
  end
end
