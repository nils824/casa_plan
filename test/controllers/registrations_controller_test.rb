require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  def registration_params(code:, extra: {})
    { user: { name: "Clara", email_address: "clara@example.test", password: "sicheres-passwort",
              password_confirmation: "sicheres-passwort", invitation_code: code }.merge(extra) }
  end

  test "registration with a wrong invitation code is refused" do
    assert_no_difference "User.count" do
      post registration_path, params: registration_params(code: "falsch123")
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Einladungscode ist ungültig/
  end

  test "registration with the invitation code creates a family member" do
    assert_difference "User.count", 1 do
      post registration_path, params: registration_params(code: "moghegno-2026")
    end

    assert_redirected_to root_path
    assert User.find_by(email_address: "clara@example.test").member?
  end

  test "role cannot be chosen during registration" do
    post registration_path, params: registration_params(code: "moghegno-2026", extra: { role: "manager" })

    assert User.find_by(email_address: "clara@example.test").member?
  end
end
