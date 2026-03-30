class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(signup_params)
    if @user.save
      start_new_session_for(@user)
      redirect_to root_path, notice: "Welcome to BookSwap, #{@user.first_name}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

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
    def signup_params
      params.require(:user).permit(:email_address, :password, :password_confirmation, :first_name, :last_name)
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :phone_number)
    end
end
