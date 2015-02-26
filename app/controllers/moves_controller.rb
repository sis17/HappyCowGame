class MovesController < ApplicationController
  before_filter :load_user

  def index
    @moves = move.all
    render :json => @moves.to_json(:include => [
      {ration: {:include => [:position]}},
      :game_user
    ])
  end

  def show
    @move = move.find(params[:id])
    render json: @move.to_json(:include => [
      {ration: {:include => [:position]}},
      :game_user
    ])
  end

  def update
    # do a check to calculate the dice, and if the 3rd dice is needed
    #if (params[:move][:ration_id] > 0 && )
    Move.update(params[:id], params.require(:move).permit(:ration_id, :selected_die))

    @move = move.find(params[:id])
    render json: @move.to_json(:include => [
      {ration: {:include => [:position]}},
      :game_user
    ])
    #@move = move.find(params[:id])
    #@move.update(params[:move])
  end

  private
  def load_user
    @game_user = GameUser.find(params[:game_user_id]) if params[:game_user_id]
    @round = Round.find(params[:round_id]) if params[:round_id]
    #@rations = @user ? @user.rations : Ration.scoped
  end

  def move
    @game_user ? @game_user.moves : (@round ? @round.moves : Ration)
  end
end
