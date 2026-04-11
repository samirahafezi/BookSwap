class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy]
  before_action :ensure_correct_user, only: %i[ show edit update destroy ]

  def index
    @books = Current.user.books.order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = Current.user.books.build
  end

  def create
    @book = Current.user.books.build(book_params)
    if @book.save
      redirect_to @book
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to @book
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @book.currently_borrowed?
      redirect_to books_path, alert: "Cannot delete a book that is currently borrowed."
    else
      @book.destroy
      redirect_to books_path
    end
  end

  def browse
    scope = Book.where(borrowable: true)
                .where.not(user_id: Current.user.id)
                .joins("LEFT JOIN borrows ON books.id = borrows.book_id AND borrows.returned_at IS NULL")
                .where(borrows: { id: nil })

    scope = scope.search(params[:q]) if params[:q].present?
    scope = scope.by_genre(params[:genre]) if params[:genre].present?

    @genres = Book.where(borrowable: true).where.not(user_id: Current.user.id).distinct.pluck(:genre).compact.sort
    @books = scope.order(created_at: :desc).page(params[:page]).per(10)
  end

  private
    def set_book
      @book = Book.find(params[:id])
    end

    def ensure_correct_user
      unless @book.user_id == Current.user.id
        redirect_to books_path, alert: "You don't have permission to access this book."
      end
    end

    def book_params
      params.require(:book).permit(:title, :author, :genre, :condition, :description, :borrowable)
    end
end
