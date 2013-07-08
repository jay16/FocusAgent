require 'test_helper'

class LuxerControllerTest < ActionController::TestCase
  test "should get labour" do
    get :labour
    assert_response :success
  end

end
