require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "new should render the signup form" do
    get signup_url
    assert_response :success
  end

  test "create should sign up a new user and start a session" do
    assert_difference("User.count", 1) do
      post signup_url, params: {
        user: {
          email_address: "new-user@example.com",
          first_name: "New",
          last_name: "User",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to root_url
    assert_equal "Welcome to BookSwap, New!", flash[:notice]
    assert_not_nil cookies[:session_id]
  end

  test "create should not sign up a user with a duplicate email address" do
    assert_no_difference("User.count") do
      post signup_url, params: {
        user: {
          email_address: @user.email_address,
          first_name: "New",
          last_name: "User",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create should not sign up a user missing a required field" do
    assert_no_difference("User.count") do
      post signup_url, params: {
        user: {
          email_address: "missing-name@example.com",
          first_name: "",
          last_name: "User",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "profile should require authentication" do
    get profile_url
    assert_redirected_to new_session_url
  end

  test "profile should show the current user's total book count" do
    login_as @user
    get profile_url
    assert_response :success
    assert_includes @response.body, "Books Added:</strong> #{@user.books.count}"
  end

  test "update should update the current user's profile" do
    login_as @user
    patch profile_url, params: { user: { first_name: "Updated", last_name: "Name", phone_number: "555-0100" } }
    assert_redirected_to profile_url
    assert_equal "Profile updated successfully.", flash[:notice]
    @user.reload
    assert_equal "Updated", @user.first_name
    assert_equal "555-0100", @user.phone_number
  end

  test "update should not update with a blank first name" do
    login_as @user
    patch profile_url, params: { user: { first_name: "" } }
    assert_response :unprocessable_entity
    assert_not_equal "", @user.reload.first_name
  end

  test "update should not permit changing email address or password through profile params" do
    login_as @user
    original_email = @user.email_address
    patch profile_url, params: { user: { first_name: @user.first_name, email_address: "hijacked@example.com", password: "newpassword123" } }
    assert_equal original_email, @user.reload.email_address
  end

  private
    def login_as(user)
      post session_url, params: { email_address: user.email_address, password: "password" }
    end
end
