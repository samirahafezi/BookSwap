class BorrowsController < ApplicationController
  def borrow
    Rails.logger.info "Borrow action called for book_id: #{params[:id]}"
    Rails.logger.info "Current user: #{Current.user.email_address}"

    @book = Book.find(params[:id])
    Rails.logger.info "Book found: #{@book.title}, owner: #{@book.user.email_address}"

    # Check if user is trying to borrow their own book
    if @book.user == Current.user
      Rails.logger.info "User trying to borrow their own book"
      redirect_to book_path(@book), alert: "You cannot borrow your own book."
      return
    end

    Rails.logger.info "Book available for borrowing: #{@book.available_for_borrowing?}"

    if @book.available_for_borrowing?
      @borrow = @book.borrows.build(
        borrower: Current.user,
        borrowed_at: Time.current
      )

      Rails.logger.info "Attempting to save borrow record"
      if @borrow.save
        Rails.logger.info "Borrow saved successfully"
        redirect_to my_borrowed_books_path, notice: "Book borrowed successfully!"
      else
        Rails.logger.error "Borrow save failed: #{@borrow.errors.full_messages}"
        redirect_to book_path(@book), alert: "Failed to borrow book: #{@borrow.errors.full_messages.join(', ')}"
      end
    else
      if @book.currently_borrowed?
        Rails.logger.info "Book is already borrowed"
        redirect_to book_path(@book), alert: "This book is already borrowed by someone else."
      else
        Rails.logger.info "Book is not borrowable"
        redirect_to book_path(@book), alert: "This book is not available for borrowing."
      end
    end
  end

  def return
    @book = Book.find(params[:id])
    @borrow = @book.borrows.active.find_by(borrower: Current.user)

    if @borrow
      @borrow.update(returned_at: Time.current)
      redirect_to book_path(@book), notice: "Book returned successfully!"
    else
      redirect_to book_path(@book), alert: "You haven't borrowed this book."
    end
  end

  def my_borrowed_books
    @borrowed_books = Current.user.currently_borrowed_books
  end
end
