require "test_helper"

class BookTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @book = @user.books.build(title: "Test Book")
  end

  test "should be valid with valid attributes" do
    assert @book.valid?
  end

  test "should require title" do
    @book.title = nil
    assert_not @book.valid?
    assert_includes @book.errors[:title], "can't be blank"
  end

  test "should require user" do
    @book.user = nil
    assert_not @book.valid?
    assert_includes @book.errors[:user], "must exist"
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
end
