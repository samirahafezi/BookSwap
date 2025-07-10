class UsersController < ApplicationController
  def profile
    @user = Current.user
    @user.total_books = @user.books.count
  end

  def update
    @user = Current.user
    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :profile, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :phone_number)
    end
end
