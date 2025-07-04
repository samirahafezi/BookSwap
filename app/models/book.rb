class Book < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  # Indicates if the book can be borrowed by others
  attribute :borrowable, :boolean, default: true
end
