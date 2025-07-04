class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy]
  before_action :ensure_correct_user, only: %i[ show edit update destroy ]

  def index
    @books = Current.user.books
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
    @book.destroy
    redirect_to books_path
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
      params.require(:book).permit(:title, :borrowable)
    end
end
