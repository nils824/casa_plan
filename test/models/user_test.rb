require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "new users are family members by default" do
    assert User.new.member?
  end

  test "password must have at least 12 characters" do
    user = User.new(name: "Clara", email_address: "clara@example.test",
                    password: "kurz-pw-123", password_confirmation: "kurz-pw-123")

    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "e-mail change to an address in use is invalid" do
    user = users(:anna)

    assert_not user.request_email_change("ben@example.test")
    assert user.errors[:unconfirmed_email].any?
  end

  test "e-mail change is applied only after confirmation" do
    user = users(:anna)

    assert user.request_email_change("anna.neu@example.test")
    assert_equal "anna@example.test", user.reload.email_address

    user.confirm_email_change!
    assert_equal "anna.neu@example.test", user.reload.email_address
    assert_nil user.email_confirmation_token
  end
end
