class GameUsersController < ApplicationController
  before_filter :load_user

  def index
    @game_users = game_user.all
    render :json => @game_users.as_json
  end

  def show
    @game_user = game_user.find(params[:id])
    render json: @game_user.as_json
  end

  private
  def load_user
    @user = User.find(params[:user_id]) if params[:user_id]
    @game = Game.find(params[:game_id]) if params[:game_id]
    #@rations = @user ? @user.rations : Ration.scoped
  end

  def game_user
    @user ? @user.game_users : (@game ? @game.game_users : GameUser)
  end
end
