require "test_helper"

class Profile::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:anna) }

  test "e-mail change sends a confirmation link and is applied after the click" do
    sign_in_as @user

    assert_enqueued_emails 1 do
      patch profile_email_path, params: { user: { unconfirmed_email: "anna.neu@example.test" } }
    end
    assert_redirected_to profile_path
    assert_equal "anna@example.test", @user.reload.email_address

    get email_confirmation_path(@user.email_confirmation_token)

    assert_redirected_to root_path
    assert_equal "anna.neu@example.test", @user.reload.email_address
  end

  test "address of another account is refused" do
    sign_in_as @user

    patch profile_email_path, params: { user: { unconfirmed_email: "ben@example.test" } }

    assert_response :unprocessable_entity
    assert_nil @user.reload.unconfirmed_email
  end

  test "invalid confirmation link shows a message" do
    get email_confirmation_path("ungueltig")

    assert_redirected_to root_path
    assert_equal "Der Bestätigungslink ist ungültig oder wurde bereits verwendet.", flash[:alert]
  end
end
