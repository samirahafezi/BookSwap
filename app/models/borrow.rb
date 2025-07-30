class Borrow < ApplicationRecord
  belongs_to :book
  belongs_to :borrower, class_name: "User"

  validates :borrowed_at, presence: true
  validate :book_is_borrowable, on: :create
  validate :book_not_already_borrowed, on: :create

  scope :active, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }

  def active?
    returned_at.nil?
  end

  def returned?
    returned_at.present?
  end

  private

  def book_is_borrowable
    unless book.borrowable?
      errors.add(:book, "is not available for borrowing")
    end
  end

  def book_not_already_borrowed
    if book.borrows.active.exists?
      errors.add(:book, "is already borrowed")
    end
  end
end
