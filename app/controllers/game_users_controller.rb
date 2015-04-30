class GameUsersController < ApplicationController
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :update, :destroy]
  before_filter :load_user

  def index
    @game_users = game_user.all
    render json: @game_users.as_json
  end

  def show
    not_found and return if !GameUser.exists?(params[:id])
    @game_user = game_user.find(params[:id])
    unauthorised and return if @game_user.user_id != @user.id
    render json: @game_user.as_json
  end

  def update
    not_found and return if !GameUser.exists?(params[:id])
    @game_user = GameUser.find(params[:id])
    unauthorised and return if @game_user.user_id != @user.id
    
    @game_user.update(params.permit(:network))
    render json: {
      success: true,
      game_user:@game_user.as_json
    }
  end

  def destroy
    not_found and return if !GameUser.exists?(params[:id])
    @game_user = GameUser.find(params[:id])
    unauthorised and return if @game_user.user_id != @user.id

    @game = @game_user.game
    messages = []
    messages.push({title:'You`ve Left', text:'You have successfully left `'+@game.name+'` game.', type:'success', time:2})

    @game_user.destroy
    if @game.game_users.count <= 0
      messages.push({title:'Game Deleted', text:'There were no more players. The game was consequently deleted.',
        type:'info', time:5})
      @game.destroy
    end

    render json: {
      success: true,
      messages: messages
    } and return
  end

  private
  def load_user
    unauthorised and return if params[:user_id] and params[:user_id] != @user.id.to_s
    #@specified_user = User.find(params[:user_id]) if params[:user_id]
    @game = Game.find(params[:game_id]) if params[:game_id]
  end

  def game_user
    params[:user_id] ? @user.game_users : (@game ? @game.game_users : GameUser)
  end
end
