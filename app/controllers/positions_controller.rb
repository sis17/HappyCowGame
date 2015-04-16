class PositionsController < ApplicationController
  before_filter :load_game

  def index
    @positions = Position.all
    render :json => @positions.as_json
  end

  def show
    @position = Position.find(params[:id])
    render :json => @position.as_json
  end

  def graph
    if params[:id] and params[:depth]
      @position = Position.find(params[:id])
      graph = @position.build_graph(params[:depth].to_f, get_taken_positions(@position))
      render json: graph and return
    end
    render :json => [] and return
  end

  private

  def get_taken_positions(current_position)
    if @game
      existing_ration = Ration.joins(:game_user).where(game_users: {game_id:@game.id}, position_id: current_position.id).take
      return @game.get_taken_positions(existing_ration) if existing_ration
    end
    return Hash.new
  end

  def load_game
    @game = Game.find(params[:game_id]) if params[:game_id]
  end
end
