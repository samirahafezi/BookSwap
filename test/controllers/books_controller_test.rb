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
      post books_url, params: { book: { title: "New Book", author: "New Author" } }
    end
    assert_redirected_to book_url(Book.last)
    assert_equal @user.id, Book.last.user_id
  end

  test "should not create book with a blank title" do
    login_as @user
    assert_no_difference("Book.count") do
      post books_url, params: { book: { title: "", author: "New Author" } }
    end
    assert_response :unprocessable_entity
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

  test "should not update book with a blank title" do
    login_as @user
    patch book_url(@book), params: { book: { title: "" } }
    assert_response :unprocessable_entity
    assert_not_equal "", @book.reload.title
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

  test "should not destroy book that is currently borrowed" do
    @book.borrows.create!(borrower: @other_user, borrowed_at: Time.current)
    login_as @user

    assert_no_difference("Book.count") do
      delete book_url(@book)
    end
    assert_redirected_to books_url
    assert_equal "Cannot delete a book that is currently borrowed.", flash[:alert]
  end

  test "browse should list borrowable books owned by other users that are not currently borrowed" do
    login_as @user
    get browse_books_url
    assert_response :success
    assert_includes @response.body, @other_user_book.title
    assert_not_includes @response.body, @book.title
  end

  test "browse should exclude books that are currently borrowed" do
    @other_user_book.borrows.create!(borrower: @user, borrowed_at: Time.current)
    login_as @user

    get browse_books_url
    assert_response :success
    assert_not_includes @response.body, @other_user_book.title
  end

  test "browse should filter by search query" do
    login_as @user
    get browse_books_url(q: @other_user_book.title)
    assert_response :success
    assert_includes @response.body, @other_user_book.title
  end

  test "browse should filter by genre" do
    login_as @user
    get browse_books_url(genre: @other_user_book.genre)
    assert_response :success
    assert_includes @response.body, @other_user_book.title
  end

  private
    def login_as(user)
      post session_url, params: { email_address: user.email_address, password: "password" }
    end
end
