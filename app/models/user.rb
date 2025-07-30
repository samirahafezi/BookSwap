class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :books, dependent: :destroy
  has_many :borrows, foreign_key: :borrower_id, dependent: :destroy
  has_many :borrowed_books, through: :borrows, source: :book

  validates :email_address, presence: true, uniqueness: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def currently_borrowed_books
    Book.joins(:borrows).where(borrows: { borrower_id: id, returned_at: nil })
  end

  def borrowing_history
    borrowed_books.joins(:borrows).order("borrows.borrowed_at DESC")
  end
end
