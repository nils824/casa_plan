require "test_helper"

class HouseTest < ActiveSupport::TestCase
  test "invitation code must have at least 8 characters" do
    house = House.new(name: "Test", beds: 2, invitation_code: "kurz")

    assert_not house.valid?
    assert house.errors[:invitation_code].any?
  end
end
