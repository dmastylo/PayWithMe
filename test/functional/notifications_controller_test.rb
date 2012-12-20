require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get read" do
    get :read
    assert_response :success
  end

end
