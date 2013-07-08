require 'test_helper'

class MailerControllerTest < ActionController::TestCase
  test "should get listener" do
    get :listener
    assert_response :success
  end

  test "should get replyer" do
    get :replyer
    assert_response :success
  end

end
