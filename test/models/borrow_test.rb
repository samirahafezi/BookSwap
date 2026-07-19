require "test_helper"

class BorrowTest < ActiveSupport::TestCase
  def setup
    @owner = users(:one)
    @borrower = users(:two)
    @book = @owner.books.create!(title: "Borrowable Book", author: "Some Author", borrowable: true)
  end

  test "should be valid with valid attributes" do
    borrow = @book.borrows.build(borrower: @borrower, borrowed_at: Time.current)
    assert borrow.valid?
  end

  test "should require borrowed_at" do
    borrow = @book.borrows.build(borrower: @borrower, borrowed_at: nil)
    assert_not borrow.valid?
    assert_includes borrow.errors[:borrowed_at], "can't be blank"
  end

  test "should be invalid when the book is not borrowable" do
    @book.update!(borrowable: false)
    borrow = @book.borrows.build(borrower: @borrower, borrowed_at: Time.current)
    assert_not borrow.valid?
    assert_includes borrow.errors[:book], "is not available for borrowing"
  end

  test "should be invalid when the book is already actively borrowed" do
    @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current)
    second_borrow = @book.borrows.build(borrower: users(:one), borrowed_at: Time.current)
    assert_not second_borrow.valid?
    assert_includes second_borrow.errors[:book], "is already borrowed"
  end

  test "should be valid to borrow a book whose previous borrow was returned" do
    @book.borrows.create!(borrower: @borrower, borrowed_at: 2.days.ago, returned_at: 1.day.ago)
    new_borrow = @book.borrows.build(borrower: @borrower, borrowed_at: Time.current)
    assert new_borrow.valid?
  end

  test "returning a borrow should not trip the already-borrowed check against its own still-active row" do
    # Without `on: :create`, this would always fail: at validation time the record's
    # own persisted row is still returned_at: nil, so book.borrows.active would match itself.
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current)
    borrow.returned_at = Time.current
    assert borrow.valid?
    assert borrow.save
  end

  test "active? should be true when returned_at is nil" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current)
    assert borrow.active?
  end

  test "active? should be false when returned_at is present" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: 1.day.ago, returned_at: Time.current)
    assert_not borrow.active?
  end

  test "returned? should be false when returned_at is nil" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current)
    assert_not borrow.returned?
  end

  test "returned? should be true when returned_at is present" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: 1.day.ago, returned_at: Time.current)
    assert borrow.returned?
  end

  test "overdue? should be false when due_at is blank" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current, due_at: nil)
    assert_not borrow.overdue?
  end

  test "overdue? should be false when due_at is in the future" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current, due_at: 1.day.from_now)
    assert_not borrow.overdue?
  end

  test "overdue? should be true when due_at is in the past and still active" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: 20.days.ago, due_at: 1.day.ago)
    assert borrow.overdue?
  end

  test "overdue? should be false once the book has been returned, even if due_at has passed" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: 20.days.ago, due_at: 1.day.ago, returned_at: Time.current)
    assert_not borrow.overdue?
  end

  test "due_soon? should be false when due_at is blank" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current, due_at: nil)
    assert_not borrow.due_soon?
  end

  test "due_soon? should be false when the borrow has already been returned" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: 1.day.ago, due_at: 1.day.from_now, returned_at: Time.current)
    assert_not borrow.due_soon?
  end

  test "due_soon? should be false when due_at is further out than the due-soon window" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current, due_at: (Borrow::DUE_SOON_WINDOW_DAYS + 1).days.from_now)
    assert_not borrow.due_soon?
  end

  test "due_soon? should be true exactly at the due-soon window boundary" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current, due_at: Borrow::DUE_SOON_WINDOW_DAYS.days.from_now)
    assert borrow.due_soon?
  end

  test "due_soon? should be false once due_at is in the past (overdue, not due soon)" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: 20.days.ago, due_at: 1.day.ago)
    assert_not borrow.due_soon?
  end

  test "active scope should return only borrows with no returned_at" do
    active = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current)
    returned = @owner.books.create!(title: "Another Book", author: "Author").borrows.create!(
      borrower: @borrower, borrowed_at: 2.days.ago, returned_at: 1.day.ago
    )

    assert_includes Borrow.active, active
    assert_not_includes Borrow.active, returned
  end

  test "returned scope should return only borrows with a returned_at" do
    active = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current)
    returned = @owner.books.create!(title: "Another Book", author: "Author").borrows.create!(
      borrower: @borrower, borrowed_at: 2.days.ago, returned_at: 1.day.ago
    )

    assert_includes Borrow.returned, returned
    assert_not_includes Borrow.returned, active
  end

  test "with_due_date scope should exclude borrows with no due_at" do
    with_due = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current, due_at: 1.day.from_now)
    without_due = @owner.books.create!(title: "Another Book", author: "Author").borrows.create!(
      borrower: @borrower, borrowed_at: Time.current, due_at: nil
    )

    assert_includes Borrow.with_due_date, with_due
    assert_not_includes Borrow.with_due_date, without_due
  end

  test "overdue scope should return only active borrows past their due date" do
    overdue = @book.borrows.create!(borrower: @borrower, borrowed_at: 20.days.ago, due_at: 1.day.ago)
    not_yet_due = @owner.books.create!(title: "Another Book", author: "Author").borrows.create!(
      borrower: @borrower, borrowed_at: Time.current, due_at: 5.days.from_now
    )

    assert_includes Borrow.overdue, overdue
    assert_not_includes Borrow.overdue, not_yet_due
  end

  test "due_soon scope should return only active borrows within the due-soon window" do
    due_soon = @book.borrows.create!(borrower: @borrower, borrowed_at: Time.current, due_at: 1.day.from_now)
    not_due_soon = @owner.books.create!(title: "Another Book", author: "Author").borrows.create!(
      borrower: @borrower, borrowed_at: Time.current, due_at: 10.days.from_now
    )

    assert_includes Borrow.due_soon, due_soon
    assert_not_includes Borrow.due_soon, not_due_soon
  end

  test "should be destroyed when its rating is destroyed" do
    borrow = @book.borrows.create!(borrower: @borrower, borrowed_at: 2.days.ago, returned_at: 1.day.ago)
    borrow.create_rating!(rater: @borrower, ratee: @owner, stars: 5)

    assert_difference "Rating.count", -1 do
      borrow.destroy
    end
  end
end
