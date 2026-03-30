class RatingsController < ApplicationController
  before_action :set_borrow

  def new
    @rating = @borrow.build_rating
  end

  def create
    @rating = @borrow.build_rating(rating_params)
    @rating.rater = Current.user
    @rating.ratee = @borrow.book.user

    if @rating.save
      redirect_to my_borrowed_books_path, notice: "Thanks for your rating!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def set_borrow
      @borrow = Current.user.borrows.find(params[:borrow_id])
    end

    def rating_params
      params.require(:rating).permit(:stars, :comment)
    end
end
