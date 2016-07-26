require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "should get configuration" do
    get :configuration
    assert_response :success
  end

end
