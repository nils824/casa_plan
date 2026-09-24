require "test_helper"

class ActivityPolicyTest < ActiveSupport::TestCase
  test "family members see the activity feed" do
    assert ActivityPolicy.new(users(:anna), Activity).index?
    assert ActivityPolicy.new(users(:manager), Activity).index?
  end

  test "guests have no access" do
    assert_not ActivityPolicy.new(nil, Activity).index?
    assert_empty ActivityPolicy::Scope.new(nil, Activity).resolve
  end

  test "the scope contains all activities for family members" do
    stays(:ben_requested).confirm_by(users(:manager))

    assert_equal 1, Activity.count
    assert_equal Activity.count, ActivityPolicy::Scope.new(users(:ben), Activity).resolve.count
  end
end