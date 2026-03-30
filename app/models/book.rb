class Book < ApplicationRecord
  belongs_to :user

  has_many :borrows, dependent: :destroy
  has_many :borrowers, through: :borrows, source: :borrower

  GENRES = %w[Fiction Non-Fiction Mystery Science\ Fiction Fantasy Biography History Romance Horror Other].freeze
  CONDITIONS = %w[New Good Fair Worn].freeze

  validates :title, presence: true
  validates :author, presence: true
  validates :condition, inclusion: { in: CONDITIONS, allow_blank: true }
  # Indicates if the book can be borrowed by others
  attribute :borrowable, :boolean, default: true

  scope :search, ->(q) {
    where("books.title LIKE :q OR books.author LIKE :q", q: "%#{q}%")
  }
  scope :by_genre, ->(g) { where(genre: g) }

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
