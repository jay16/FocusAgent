require 'test_helper'

class DispatcherControllerTest < ActionController::TestCase
  test "should get task" do
    get :task
    assert_response :success
  end

  test "should get check" do
    get :check
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

end
