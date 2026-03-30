class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :books, dependent: :destroy
  has_many :borrows, foreign_key: :borrower_id, dependent: :destroy
  has_many :borrowed_books, through: :borrows, source: :book
  has_many :ratings_received, class_name: "Rating", foreign_key: :ratee_id, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def average_rating
    return nil if ratings_received.empty?
    ratings_received.average(:stars).round(1)
  end

  def currently_borrowed_books
    Book.joins(:borrows).where(borrows: { borrower_id: id, returned_at: nil })
  end

  def borrowing_history
    borrowed_books.joins(:borrows).order("borrows.borrowed_at DESC")
  end
end
