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
      if @user
        if @user.password == params[:password]
          success = true
          render json: { success: true, user: @user.as_json, messages: []} and return
        else

        end

        render json: {
          success: false,
          messages: [{title: 'Wrong Password', text: 'Please try again, your password was incorrect.', type: 'danger'}]
        } and return
      else
        render json: {
          success: false,
          messages: [{title: 'Not an Account', text: 'Please try again with a diffrent email, it was not recognised.', type: 'danger'}]
        } and return
      end
    end

    render json: {
      success: false,
      messages: [{title: 'Authorisation Failed', text: 'Your account does not exist, or you gave us the wrong email.', type: 'danger'}]
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
    success = false
    user = nil
    messages = []

    existing_user = User.find_by email: params[:user][:email]
    if existing_user
      messages.push({title: 'User Account Exists', text: 'We already have an account registered for that email, try signing in.', type: 'warning', time: 6})
    else
      @user = User.new(params.require(:user).permit(:email, :name, :password))
      if @user
        @user.experience = 0
        @user.colour = "%06x" % (rand * 0xffffff)
        @user.save
        render json: {
          success: true,
          user: @user,
          messages: [{title: 'Account Created', text: 'Your account has been created. Pleaes remember your details.', type: 'success', time: 4}]
        } and return
      end
      messages.push({title: 'Oops', text: 'The account could not be created, make sure you enter all necessary details.', type: 'warning', time: 5})
    end

    render json: {
      success: success,
      user: user,
      messages: messages
    } and return
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end
end
