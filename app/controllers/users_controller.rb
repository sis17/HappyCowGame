class UsersController < ApplicationController
  #before_action :set_user, only: [:show, :edit, :update, :destroy]
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :update, :destroy]

  def index
    @users = User.order('name')
    render :json => @users.as_json
  end

  def show
    unauthorised and return if params[:id] != @user.id.to_s # check user is authenticated
    render json: @user.as_json and return
  end

  def update
    #@user = User.find(params[:id])
    unauthorised and return if params[:id] != @user.id.to_s # check user is authenticated

    if params[:profile]
      @user.update(params.require(:profile).permit(:email, :name, :colour, :password))
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

  def login
    if (params[:email] && params[:password])
      @user = User.find_by email: params[:email]
      if @user
        if @user.password == params[:password]
          success = true
          @user.last_logged_in = DateTime.now
          @user.key = SecureRandom.base64.tr('+/=', 'Qrt')
          @user.save
          render json: { success: true, user: @user.as_json, key: @user.key, messages: []} and return # successful login
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

  # POST /users
  def create
    success = false
    user = nil
    messages = []

    existing_user = User.find_by email: params[:user][:email]
    if existing_user
      messages.push({title: 'User Account Exists', text: 'We already have an account registered for that email, try signing in.', type: 'warning', time: 6})
    elsif !params[:user][:email] || !params[:user][:password]
      messages.push({title: 'Oops', text: 'The account could not be created, make sure you enter all necessary details.', type: 'warning', time: 5})
    else
      @user = User.new(params.require(:user).permit(:email, :name, :password))
      if @user
        @user.experience = 0
        @user.colour = '#'+("%06x" % (rand * 0xffffff))
        @user.last_logged_in = DateTime.now
        @user.key = SecureRandom.base64.tr('+/=', 'Qrt')
        @user.save
        render json: {
          success: true,
          user: @user.as_json,
          key: @user.key,
          messages: [{title: 'Account Created', text: 'Your account has been created. Please remember your details.', type: 'success', time: 4}]
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
end
