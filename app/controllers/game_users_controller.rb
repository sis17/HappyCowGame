class GameUsersController < ApplicationController
  before_filter :load_user

  def index
    @game_users = game_user.all
    render json: @game_users.as_json
  end

  def show
    @game_user = game_user.find(params[:id])
    render json: @game_user.as_json
  end

  def destroy
    @game_user = GameUser.find(params[:id])
    @game = @game_user.game
    message = 'You have successfully left `'+@game.name+'` game.'

    @game_user.destroy
    if @game.game_users.count <= 0
      message += ' The game was consequently deleted.'
      @game.destroy
    end
    render json: {
      success: true,
      message: {title:'You have left', text:message, type:'success'}
    } and return
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
