class BorrowsMailer < ApplicationMailer
  def due_soon(borrow)
    @borrow = borrow
    @user = borrow.borrower
    @book = borrow.book
    mail to: @user.email_address, subject: "Book due soon: #{@book.title}"
  end

  def overdue(borrow)
    @borrow = borrow
    @user = borrow.borrower
    @book = borrow.book
    mail to: @user.email_address, subject: "Overdue book: #{@book.title}"
  end
end

