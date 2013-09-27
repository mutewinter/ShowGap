require "test_helper"

class UserTest < MiniTest::Rails::ActiveSupport::TestCase
  test "user permissions" do
    ability = Ability.new(Fabricate(:listener))

    assert(ability.can?(:create, Reply), "can create replies")
    refute(ability.can?(:manage, Discussion), "can't manage discussions")
  end
end
