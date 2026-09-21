require "test_helper"

class StayPolicyTest < ActiveSupport::TestCase
  def policy(user, stay)
    StayPolicy.new(user, stay)
  end

  test "guests have no access" do
    assert_not policy(nil, stays(:ben_requested)).show?
    assert_not policy(nil, stays(:ben_requested)).create?
    assert_empty StayPolicy::Scope.new(nil, Stay).resolve
  end

  test "all family members see all stays" do
    assert policy(users(:anna), stays(:ben_requested)).show?
    assert_equal Stay.count, StayPolicy::Scope.new(users(:anna), Stay).resolve.count
  end

  test "member edits and withdraws own open request" do
    assert policy(users(:ben), stays(:ben_requested)).edit?
    assert policy(users(:ben), stays(:ben_requested)).withdraw?
  end

  test "member cannot edit or withdraw another member's request" do
    assert_not policy(users(:anna), stays(:ben_requested)).edit?
    assert_not policy(users(:anna), stays(:ben_requested)).update?
    assert_not policy(users(:anna), stays(:ben_requested)).withdraw?
  end

  test "manager may edit requests of others" do
    assert policy(users(:manager), stays(:ben_requested)).edit?
  end

  test "decided stays are not offered for editing" do
    assert_not policy(users(:anna), stays(:anna_confirmed)).edit?
    assert_not policy(users(:manager), stays(:anna_confirmed)).edit?
  end

  test "only the manager confirms and rejects" do
    assert policy(users(:manager), stays(:ben_requested)).confirm?
    assert policy(users(:manager), stays(:ben_requested)).reject?
    assert_not policy(users(:ben), stays(:ben_requested)).confirm?
    assert_not policy(users(:ben), stays(:ben_requested)).reject?
  end
end
