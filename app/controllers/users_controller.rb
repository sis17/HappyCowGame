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

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
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
