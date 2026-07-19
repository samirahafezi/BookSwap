require "test_helper"

class RatingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @owner = users(:one)
    @borrower = users(:two)
    @book = @owner.books.create!(title: "Rated Book", author: "Some Author")
    @borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: 2.days.ago, returned_at: 1.day.ago)
  end

  test "new should render for the borrower of a returned borrow" do
    login_as @borrower
    get new_borrow_rating_url(@borrow)
    assert_response :success
  end

  test "new should 404 for a borrow that does not belong to the current user" do
    login_as @owner
    get new_borrow_rating_url(@borrow)
    assert_response :not_found
  end

  test "create should save a rating and redirect when valid" do
    login_as @borrower
    assert_difference("Rating.count", 1) do
      post borrow_rating_url(@borrow), params: { rating: { stars: 5, comment: "Great book!" } }
    end
    assert_redirected_to my_borrowed_books_url
    assert_equal "Thanks for your rating!", flash[:notice]
    assert_equal @borrower, @borrow.rating.rater
    assert_equal @owner, @borrow.rating.ratee
  end

  test "create should re-render with an error when stars is out of range" do
    login_as @borrower
    assert_no_difference("Rating.count") do
      post borrow_rating_url(@borrow), params: { rating: { stars: 6, comment: "Great book!" } }
    end
    assert_response :unprocessable_entity
  end

  test "create does not block a second submission for an already-rated borrow" do
    # This documents current (buggy) behavior rather than the intended one: the
    # uniqueness validation on Rating#borrow_id can never fire through this action.
    # @borrow.build_rating (called in RatingsController#create) goes through the
    # has_one :rating association; since Rating.borrow_id is NOT NULL, has_one's
    # replace-on-build destroys the existing rating as a side effect of building the
    # new one, before validation runs — so a double-submit silently replaces the
    # original rating instead of being rejected with "has already been rated".
    login_as @borrower
    post borrow_rating_url(@borrow), params: { rating: { stars: 5, comment: "First rating" } }
    first_rating_id = @borrow.reload.rating.id

    assert_no_difference("Rating.count") do
      post borrow_rating_url(@borrow), params: { rating: { stars: 1, comment: "Second rating" } }
    end
    assert_redirected_to my_borrowed_books_url
    assert_not_equal first_rating_id, @borrow.reload.rating.id
    assert_equal 1, @borrow.rating.stars
  end

  private
    def login_as(user)
      post session_url, params: { email_address: user.email_address, password: "password" }
    end
end
