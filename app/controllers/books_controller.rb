class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy]
  before_action :authenticate_user!
  before_action :ensure_owner!, only: %i[edit update destroy]

  def index
    @books = Current.user.books
  end

  def show
  end

  def new
    @book = Book.new
  end

  def create
    @book = Current.user.books.new(book_params)
    if @book.save
      redirect_to @book
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
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

    def book_params
      params.require(:book).permit(:title)
    end

    def authenticate_user!
      redirect_to new_session_path unless Current.user
    end

    def ensure_owner!
      redirect_to books_path unless @book.user == Current.user
    end
end
