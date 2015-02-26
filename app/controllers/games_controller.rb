class GamesController < ApplicationController
  def index
    @games = Game.includes({game_users: :user}, :rounds, {round: :event}).all
    render :json => @games
  end

  def show
    @game = Game.includes({game_users: :user}, :rounds, {round: :event}).find(params[:id])
    render :json => @game
  end

  def update
    @game = Game.find(params[:id])
    # do a check to see if the game is in the review phase, if so, allow update of round_id
    if (@game.round.current_phase == 4)
      @game.update(params.require(:game).permit(:round_id))
    end

    # return the game
    render :json => @game
  end

  # POST /games.json
  def create
    @game = Game.new(game_params)
  end

end
