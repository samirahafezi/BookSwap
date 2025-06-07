require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @book = books(:book_one)
    @other_user_book = books(:book_two)
  end

  test "should get index when logged in" do
    login_as @user
    get books_url
    assert_response :success
    assert_includes @response.body, @book.title
    assert_not_includes @response.body, @other_user_book.title
  end

  test "should redirect index when not logged in" do
    get books_url
    assert_redirected_to new_session_url
  end

  test "should get new when logged in" do
    login_as @user
    get new_book_url
    assert_response :success
  end

  test "should create book when logged in" do
    login_as @user
    assert_difference("Book.count") do
      post books_url, params: { book: { title: "New Book" } }
    end
    assert_redirected_to book_url(Book.last)
    assert_equal @user.id, Book.last.user_id
  end

  test "should show book when logged in as owner" do
    login_as @user
    get book_url(@book)
    assert_response :success
  end

  test "should not show book when logged in as different user" do
    login_as @user
    get book_url(@other_user_book)
    assert_redirected_to books_url
    assert_equal "You don't have permission to access this book.", flash[:alert]
  end

  test "should get edit when logged in as owner" do
    login_as @user
    get edit_book_url(@book)
    assert_response :success
  end

  test "should not get edit when logged in as different user" do
    login_as @user
    get edit_book_url(@other_user_book)
    assert_redirected_to books_url
    assert_equal "You don't have permission to access this book.", flash[:alert]
  end

  test "should update book when logged in as owner" do
    login_as @user
    patch book_url(@book), params: { book: { title: "Updated Title" } }
    assert_redirected_to book_url(@book)
    @book.reload
    assert_equal "Updated Title", @book.title
  end

  test "should not update book when logged in as different user" do
    login_as @user
    patch book_url(@other_user_book), params: { book: { title: "Updated Title" } }
    assert_redirected_to books_url
    assert_equal "You don't have permission to access this book.", flash[:alert]
    @other_user_book.reload
    assert_not_equal "Updated Title", @other_user_book.title
  end

  test "should destroy book when logged in as owner" do
    login_as @user
    assert_difference("Book.count", -1) do
      delete book_url(@book)
    end
    assert_redirected_to books_url
  end

  test "should not destroy book when logged in as different user" do
    login_as @user
    assert_no_difference("Book.count") do
      delete book_url(@other_user_book)
    end
    assert_redirected_to books_url
    assert_equal "You don't have permission to access this book.", flash[:alert]
  end

  private
    def login_as(user)
      post session_url, params: { email_address: user.email_address, password: "password" }
    end
end
