class Book < ApplicationRecord
  belongs_to :user

  has_many :borrows, dependent: :destroy
  has_many :borrowers, through: :borrows, source: :borrower

  validates :title, presence: true
  # Indicates if the book can be borrowed by others
  attribute :borrowable, :boolean, default: true

  def currently_borrowed?
    borrows.active.exists?
  end

  def current_borrower
    borrows.active.first&.borrower
  end

  def current_borrow
    borrows.active.first
  end

  def available_for_borrowing?
    borrowable? && !currently_borrowed?
  end
end
