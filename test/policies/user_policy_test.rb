require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "only the manager manages users" do
    assert UserPolicy.new(users(:manager), User).index?
    assert_not UserPolicy.new(users(:anna), User).index?
    assert_not UserPolicy.new(nil, User).index?
  end

  test "manager may change the role of others but not the own role" do
    assert_includes UserPolicy.new(users(:manager), users(:ben)).permitted_attributes, :role
    assert_not_includes UserPolicy.new(users(:manager), users(:manager)).permitted_attributes, :role
  end

  test "members see no users in the admin scope" do
    assert_empty UserPolicy::Scope.new(users(:anna), User).resolve
  end
end
