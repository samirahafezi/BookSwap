require "test_helper"

class BorrowsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @owner = users(:one)
    @borrower = users(:two)
    @book = @owner.books.create!(title: "Borrowable Book", author: "Some Author", borrowable: true)
  end

  test "borrow should redirect to my borrowed books and create a borrow when logged in" do
    login_as @borrower
    assert_difference("Borrow.count", 1) do
      post borrow_book_url(@book)
    end
    assert_redirected_to my_borrowed_books_url
    assert_equal @borrower, @book.reload.current_borrower
  end

  test "borrow should set a due date based on the loan period" do
    login_as @borrower
    travel_to Time.zone.parse("2026-01-01 12:00") do
      post borrow_book_url(@book)
    end
    assert_equal Time.zone.parse("2026-01-01 12:00") + Borrow::LOAN_PERIOD_DAYS.days, @book.reload.current_borrow.due_at
  end

  test "borrow should redirect without creating a borrow when the user owns the book" do
    login_as @owner
    assert_no_difference("Borrow.count") do
      post borrow_book_url(@book)
    end
    assert_redirected_to book_url(@book)
    assert_equal "You cannot borrow your own book.", flash[:alert]
  end

  test "borrow should redirect without creating a borrow when the book is not borrowable" do
    @book.update!(borrowable: false)
    login_as @borrower
    assert_no_difference("Borrow.count") do
      post borrow_book_url(@book)
    end
    assert_redirected_to book_url(@book)
    assert_equal "This book is not available for borrowing.", flash[:alert]
  end

  test "borrow should redirect without creating a borrow when the book is already borrowed by someone else" do
    other_borrower = User.create!(email_address: "third@example.com", first_name: "Third", last_name: "Wheel", password: "password123")
    @book.borrows.create!(borrower: other_borrower, borrowed_at: Time.current)

    login_as @borrower
    assert_no_difference("Borrow.count") do
      post borrow_book_url(@book)
    end
    assert_redirected_to book_url(@book)
    assert_equal "This book is already borrowed by someone else.", flash[:alert]
  end

  test "return should mark the active borrow as returned and redirect to the new rating page" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current)
    login_as @borrower

    post return_book_url(@book)

    assert borrow.reload.returned?
    assert_redirected_to new_borrow_rating_url(borrow)
    assert_equal "Book returned! Leave a rating for the owner.", flash[:notice]
  end

  test "return should redirect with an alert when the user has no active borrow on the book" do
    login_as @borrower
    post return_book_url(@book)
    assert_redirected_to book_url(@book)
    assert_equal "You haven't borrowed this book.", flash[:alert]
  end

  test "my_borrowed_books should list the current user's active borrows" do
    @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current)
    login_as @borrower

    get my_borrowed_books_url
    assert_response :success
    assert_includes @response.body, @book.title
  end

  test "borrowing_history should list the current user's past borrows" do
    @book.borrows.create!(borrower: @borrower, borrowed_at: 2.days.ago, returned_at: 1.day.ago)
    login_as @borrower

    get borrowing_history_url
    assert_response :success
    assert_includes @response.body, @book.title
  end

  test "my_books_borrowers should list borrowers of the current user's books" do
    @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current)
    login_as @owner

    get my_books_borrowers_url
    assert_response :success
    assert_includes @response.body, @borrower.email_address
  end

  test "index actions should redirect when not logged in" do
    get my_borrowed_books_url
    assert_redirected_to new_session_url
  end

  private
    def login_as(user)
      post session_url, params: { email_address: user.email_address, password: "password" }
    end
end
