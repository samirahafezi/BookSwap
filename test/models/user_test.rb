require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user = User.new(email_address: "test@example.com", first_name: "Test", last_name: "User", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "should require first name" do
    user = User.new(email_address: "test@example.com", last_name: "User", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "should require last name" do
    user = User.new(email_address: "test@example.com", first_name: "Test", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "should normalize email address" do
    user = User.new(email_address: " TEST@EXAMPLE.COM ", first_name: "Test", last_name: "User", password: "password123")
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

  test "average_rating should be nil when user has received no ratings" do
    assert_nil users(:two).average_rating
  end

  test "average_rating should return the rounded mean of received ratings" do
    owner = users(:two)
    borrower = users(:one)
    borrow_one = borrows_via_new_book(owner: owner, borrower: borrower, returned: true)
    borrow_two = borrows_via_new_book(owner: owner, borrower: borrower, returned: true)
    borrow_one.create_rating!(rater: borrower, ratee: owner, stars: 4)
    borrow_two.create_rating!(rater: borrower, ratee: owner, stars: 5)

    assert_equal 4.5, owner.average_rating
  end

  test "currently_borrowed_books should include only books the user has an active borrow on" do
    borrower = users(:one)
    active_borrow = borrows_via_new_book(owner: users(:two), borrower: borrower, returned: false)
    returned_borrow = borrows_via_new_book(owner: users(:two), borrower: borrower, returned: true)

    assert_includes borrower.currently_borrowed_books, active_borrow.book
    assert_not_includes borrower.currently_borrowed_books, returned_borrow.book
  end

  test "borrowing_history should order borrowed books by borrowed_at descending" do
    borrower = users(:one)
    older = borrows_via_new_book(owner: users(:two), borrower: borrower, returned: true, borrowed_at: 10.days.ago)
    newer = borrows_via_new_book(owner: users(:two), borrower: borrower, returned: true, borrowed_at: 1.day.ago)

    assert_equal [ newer.book, older.book ], borrower.borrowing_history.first(2)
  end

  private
    def borrows_via_new_book(owner:, borrower:, returned:, borrowed_at: Time.current)
      book = owner.books.create!(title: "Borrowed Book #{SecureRandom.hex(4)}", author: "Some Author")
      book.borrows.create!(
        borrower: borrower,
        borrowed_at: borrowed_at,
        returned_at: returned ? borrowed_at + 1.day : nil
      )
    end
end
