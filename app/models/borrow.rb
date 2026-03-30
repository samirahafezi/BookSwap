class Borrow < ApplicationRecord
  belongs_to :book
  belongs_to :borrower, class_name: "User"
  has_one :rating, dependent: :destroy

  LOAN_PERIOD_DAYS = 14
  DUE_SOON_WINDOW_DAYS = 2

  validates :borrowed_at, presence: true
  validate :book_is_borrowable, on: :create
  validate :book_not_already_borrowed, on: :create

  scope :active, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }
  scope :with_due_date, -> { where.not(due_at: nil) }
  scope :overdue, -> { active.with_due_date.where("due_at < ?", Time.current) }
  scope :due_soon, -> {
    active.with_due_date.where(due_at: Time.current..(Time.current + DUE_SOON_WINDOW_DAYS.days))
  }

  def active?
    returned_at.nil?
  end

  def returned?
    returned_at.present?
  end

  def overdue?
    due_at.present? && due_at < Time.current && active?
  end

  def due_soon?
    return false unless due_at.present? && active?

    due_at >= Time.current && due_at <= Time.current + DUE_SOON_WINDOW_DAYS.days
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
