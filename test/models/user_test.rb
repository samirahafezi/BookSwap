require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user = User.new(email_address: "test@example.com", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "should normalize email address" do
    user = User.new(email_address: " TEST@EXAMPLE.COM ", password: "password123")
    user.valid?
    assert_equal "test@example.com", user.email_address
  end

  test "should require email address" do
    user = User.new(password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "should require unique email address" do
    existing_user = users(:one)
    user = User.new(email_address: existing_user.email_address, password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "should require password" do
    user = User.new(email_address: "test@example.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "should authenticate with correct password" do
    user = users(:one)
    assert user.authenticate("password")
  end

  test "should not authenticate with incorrect password" do
    user = users(:one)
    assert_not user.authenticate("wrong_password")
  end

  test "should have many books" do
    user = users(:one)
    assert_respond_to user, :books
    assert_includes user.books, books(:book_one)
    assert_includes user.books, books(:book_three)
  end

  test "should have many sessions" do
    user = users(:one)
    assert_respond_to user, :sessions
  end

  test "should destroy associated books when destroyed" do
    user = users(:one)
    assert_difference "Book.count", -2 do
      user.destroy
    end
  end

  test "should destroy associated sessions when destroyed" do
    user = users(:one)
    user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test Agent")
    assert_difference "Session.count", -1 do
      user.destroy
    end
  end
end
