require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "new should render the request form" do
    get new_password_url
    assert_response :success
  end

  test "create should enqueue a reset email when the address exists" do
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ] do
      post passwords_url, params: { email_address: @user.email_address }
    end
    assert_redirected_to new_session_url
  end

  test "create should redirect the same way when the address does not exist, to avoid revealing which emails are registered" do
    assert_no_enqueued_emails do
      post passwords_url, params: { email_address: "nobody@example.com" }
    end
    assert_redirected_to new_session_url
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "edit should render for a valid token" do
    get edit_password_url(@user.password_reset_token)
    assert_response :success
  end

  test "edit should redirect for an invalid token" do
    get edit_password_url("not-a-real-token")
    assert_redirected_to new_password_url
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end

  test "edit should redirect for an expired token" do
    token = @user.password_reset_token
    travel_to(20.minutes.from_now) do
      get edit_password_url(token)
    end
    assert_redirected_to new_password_url
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end

  test "update should reset the password when confirmation matches" do
    token = @user.password_reset_token
    patch password_url(token), params: { password: "newpassword123", password_confirmation: "newpassword123" }
    assert_redirected_to new_session_url
    assert_equal "Password has been reset.", flash[:notice]
    assert @user.reload.authenticate("newpassword123")
  end

  test "update should not reset the password when confirmation does not match" do
    token = @user.password_reset_token
    original_digest = @user.password_digest
    patch password_url(token), params: { password: "newpassword123", password_confirmation: "different123" }
    assert_redirected_to edit_password_url(token)
    assert_equal "Passwords did not match.", flash[:alert]
    assert_equal original_digest, @user.reload.password_digest
  end

  test "update should redirect for an invalid token" do
    patch password_url("not-a-real-token"), params: { password: "newpassword123", password_confirmation: "newpassword123" }
    assert_redirected_to new_password_url
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end
end
