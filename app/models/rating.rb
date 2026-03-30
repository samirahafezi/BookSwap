class Rating < ApplicationRecord
  belongs_to :borrow
  belongs_to :rater, class_name: "User"
  belongs_to :ratee, class_name: "User"

  validates :stars, inclusion: { in: 1..5, message: "must be between 1 and 5" }
  validates :borrow_id, uniqueness: { message: "has already been rated" }

  validate :borrow_must_be_returned
  validate :rater_must_be_borrower

  private

    def borrow_must_be_returned
      errors.add(:base, "You can only rate after returning the book") unless borrow&.returned?
    end

    def rater_must_be_borrower
      errors.add(:base, "Only the borrower can leave a rating") unless borrow&.borrower_id == rater_id
    end
end
