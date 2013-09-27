require "test_helper"

class VoteTest < MiniTest::Rails::ActiveSupport::TestCase
  test "user can't vote twice in a discussion poll" do
    poll = Fabricate(:poll)
    reply1 = Fabricate(:reply, discussion: poll)
    reply2 = Fabricate(:reply, discussion: poll)
    user = Fabricate(:listener)

    user.vote_for reply1
    assert_raises ActiveRecord::RecordInvalid do
      user.vote_for reply2
    end
  end
end
