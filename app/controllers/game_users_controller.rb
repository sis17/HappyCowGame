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
    @user = User.find(params[:user_id]) if params[:user_id]
    @game = Game.find(params[:game_id]) if params[:game_id]
    #@rations = @user ? @user.rations : Ration.scoped
  end

  def game_user
    @user ? @user.game_users : (@game ? @game.game_users : GameUser)
  end
end
