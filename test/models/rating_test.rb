require "test_helper"

class RatingTest < ActiveSupport::TestCase
  def setup
    @owner = users(:one)
    @borrower = users(:two)
    @book = @owner.books.create!(title: "Rated Book", author: "Some Author")
    @borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: 2.days.ago, returned_at: 1.day.ago)
  end

  test "should be valid with valid attributes" do
    rating = @borrow.build_rating(rater: @borrower, ratee: @owner, stars: 4)
    assert rating.valid?
  end

  test "should require stars to be present" do
    rating = @borrow.build_rating(rater: @borrower, ratee: @owner, stars: nil)
    assert_not rating.valid?
    assert_includes rating.errors[:stars], "must be between 1 and 5"
  end

  test "should reject stars below the allowed range" do
    rating = @borrow.build_rating(rater: @borrower, ratee: @owner, stars: 0)
    assert_not rating.valid?
    assert_includes rating.errors[:stars], "must be between 1 and 5"
  end

  test "should reject stars above the allowed range" do
    rating = @borrow.build_rating(rater: @borrower, ratee: @owner, stars: 6)
    assert_not rating.valid?
    assert_includes rating.errors[:stars], "must be between 1 and 5"
  end

  test "should accept stars at the boundaries of the allowed range" do
    low = @borrow.build_rating(rater: @borrower, ratee: @owner, stars: 1)
    assert low.valid?

    high = @borrow.build_rating(rater: @borrower, ratee: @owner, stars: 5)
    assert high.valid?
  end

  test "should not allow a borrow to be rated twice" do
    @borrow.create_rating!(rater: @borrower, ratee: @owner, stars: 5)
    # NOTE: deliberately not using @borrow.build_rating here. Because Rating.borrow_id
    # is NOT NULL, has_one's replace-on-build immediately destroys the existing rating
    # as a side effect of building a new one — before validation ever runs — which
    # would mask the exact conflict this test exists to prove. See RatingsController
    # finding reported separately: this means the uniqueness check can't actually stop
    # a double-submit through the real controller flow.
    second = Rating.new(borrow_id: @borrow.id, rater: @borrower, ratee: @owner, stars: 3)
    assert_not second.valid?
    assert_includes second.errors[:borrow_id], "has already been rated"
  end

  test "should be invalid when the borrow has not been returned" do
    active_borrow = @book.borrows.create!(borrower: users(:one), borrowed_at: Time.current)
    rating = active_borrow.build_rating(rater: users(:one), ratee: @owner, stars: 5)
    assert_not rating.valid?
    assert_includes rating.errors[:base], "You can only rate after returning the book"
  end

  test "should be invalid when the rater is not the borrower" do
    rating = @borrow.build_rating(rater: @owner, ratee: @borrower, stars: 5)
    assert_not rating.valid?
    assert_includes rating.errors[:base], "Only the borrower can leave a rating"
  end

  test "should be destroyed when its borrow is destroyed" do
    @borrow.create_rating!(rater: @borrower, ratee: @owner, stars: 5)
    assert_difference "Rating.count", -1 do
      @borrow.destroy
    end
  end
end
