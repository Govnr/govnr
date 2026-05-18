require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should follow and unfollow a user" do
    one = users(:one)
    two  = users(:two)
    assert_not one.following?(two)
    one.follow(two)
    assert one.following?(two)
    assert two.followers.include?(one)
    one.unfollow(two)
    assert_not one.following?(two)
  end

end
