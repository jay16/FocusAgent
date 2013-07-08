require 'test_helper'

class AgentControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get flux" do
    get :flux
    assert_response :success
  end

  test "should get tasks" do
    get :tasks
    assert_response :success
  end

end
