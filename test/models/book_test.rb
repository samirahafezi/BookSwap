require "test_helper"

class BookTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @book = @user.books.build(title: "Test Book", author: "Test Author")
  end

  test "should be valid with valid attributes" do
    assert @book.valid?
  end

  test "should require title" do
    @book.title = nil
    assert_not @book.valid?
    assert_includes @book.errors[:title], "can't be blank"
  end

  test "should require author" do
    @book.author = nil
    assert_not @book.valid?
    assert_includes @book.errors[:author], "can't be blank"
  end

  test "should require user" do
    @book.user = nil
    assert_not @book.valid?
    assert_includes @book.errors[:user], "must exist"
  end

  test "should allow a condition from the defined list" do
    @book.condition = "Good"
    assert @book.valid?
  end

  test "should reject a condition outside the defined list" do
    @book.condition = "Pristine"
    assert_not @book.valid?
    assert_includes @book.errors[:condition], "is not included in the list"
  end

  test "should allow a blank condition" do
    @book.condition = nil
    assert @book.valid?
  end

  test "should belong to user" do
    assert_equal users(:one), books(:book_one).user
  end

  test "user should have multiple books" do
    user = users(:one)
    assert_includes user.books, books(:book_one)
    assert_includes user.books, books(:book_three)
  end

  test "should be destroyed when user is destroyed" do
    user = users(:one)
    assert_difference "Book.count", -2 do
      user.destroy
    end
  end

  test "available_for_borrowing? should be true when borrowable and not currently borrowed" do
    @book.borrowable = true
    @book.save!
    assert @book.available_for_borrowing?
  end

  test "available_for_borrowing? should be false when not borrowable" do
    @book.borrowable = false
    @book.save!
    assert_not @book.available_for_borrowing?
  end

  test "available_for_borrowing? should be false when currently borrowed" do
    @book.save!
    @book.borrows.create!(borrower: users(:two), borrowed_at: Time.current)
    assert_not @book.available_for_borrowing?
  end

  test "currently_borrowed? should be false with no borrows" do
    @book.save!
    assert_not @book.currently_borrowed?
  end

  test "currently_borrowed? should be false when the only borrow was returned" do
    @book.save!
    @book.borrows.create!(borrower: users(:two), borrowed_at: 2.days.ago, returned_at: 1.day.ago)
    assert_not @book.currently_borrowed?
  end

  test "currently_borrowed? should be true with an active borrow" do
    @book.save!
    @book.borrows.create!(borrower: users(:two), borrowed_at: Time.current)
    assert @book.currently_borrowed?
  end

  test "current_borrower should return nil when not currently borrowed" do
    @book.save!
    assert_nil @book.current_borrower
  end

  test "current_borrower should return the active borrower" do
    @book.save!
    borrower = users(:two)
    @book.borrows.create!(borrower: borrower, borrowed_at: Time.current)
    assert_equal borrower, @book.current_borrower
  end

  test "current_borrow should return nil when not currently borrowed" do
    @book.save!
    assert_nil @book.current_borrow
  end

  test "current_borrow should return the active borrow record" do
    @book.save!
    active = @book.borrows.create!(borrower: users(:two), borrowed_at: Time.current)
    assert_equal active, @book.current_borrow
  end

  test "search scope should match a partial title" do
    assert_includes Book.search("Gatsby"), books(:book_one)
    assert_not_includes Book.search("Gatsby"), books(:book_two)
  end

  test "search scope should match a partial author" do
    assert_includes Book.search("Orwell"), books(:book_two)
    assert_not_includes Book.search("Orwell"), books(:book_one)
  end

  test "by_genre scope should match only the given genre" do
    assert_includes Book.by_genre("Fiction"), books(:book_one)
    assert_not_includes Book.by_genre("Fiction"), books(:book_two)
  end
end
