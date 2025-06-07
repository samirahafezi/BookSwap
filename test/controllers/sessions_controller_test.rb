require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    post session_url, params: { email_address: @user.email_address, password: "password" }
    assert_redirected_to root_url
    assert_equal @user.id, Session.last.user_id
  end

  test "should not create session with invalid credentials" do
    post session_url, params: { email_address: @user.email_address, password: "wrong_password" }
    assert_redirected_to new_session_url
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "should destroy session" do
    login_as @user
    assert_difference("Session.count", -1) do
      delete session_url
    end
    assert_redirected_to new_session_url
  end

  test "should redirect to requested url after authentication" do
    get books_url
    assert_redirected_to new_session_url
    post session_url, params: { email_address: @user.email_address, password: "password" }
    assert_redirected_to books_url
  end

  private
    def login_as(user)
      post session_url, params: { email_address: user.email_address, password: "password" }
    end
end
