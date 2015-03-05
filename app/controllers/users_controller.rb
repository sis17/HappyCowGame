class UsersController < ApplicationController
  #before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.includes(:game_users).order('name')
    render :json => @users.to_json(:include => :game_users)
  end

  def show
    @user = User.includes(:game_users, :games).find(params[:id])
    render json: @user.to_json(:include => :game_users, :include => :games)
  end

  # GET /users/login
  def login
    if (params[:email] && params[:password])
      @user = User.find_by email: params[:email]
      if (@user.password == params[:password])
        render json: { success: true, user: @user.as_json} and return
      end

      render json: {
        success: false,
        message: {title: 'Wrong Password', text: 'Please try again, your password was incorrect.', type: 'danger'}
      } and return
    end

    render json: {
      success: false,
      message: {title: 'Authorisation Failed', text: 'Your account does not exist, or you gave us the wrong email.', type: 'danger'}
    } and return
  end

  def update
    @user = User.find(params[:id])
    if params[:profile]
      @user.update(params.require(:profile).permit(:email, :name, :colour))
      render json: {
        success: true,
        message: {title: 'Profile Saved', text: 'Your profile has been updated.', type: 'success'}
      } and return
    end

    render json: {
      success: false,
      message: {title: 'You Must Update a Profile', text: 'You are not updating user details correctly, by editing your profile.', type: 'warning'}
    } and return
  end

  # POST /users
  # POST /users.json
  # At the moment we are only allowing the admin user to create new
  # accounts.
  def create
    @user = User.new(user_params)
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end
end
