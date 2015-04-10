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
      graph = build_graph(@position, params[:depth].to_f, get_taken_positions)
      render json: graph and return
    end
    render :json => [] and return
  end

  private

  def build_graph(position, depth, taken_positions)
    graph = {}
    # create the position, if not already there
    build_position(graph, position, taken_positions)
    next_positions = position.positions

    while depth > 0 do
      depth -= 1
      next_next_positions = []

      next_positions.each do |next_position|
        # create the position, if not already there
        added = build_position(graph, next_position, taken_positions)
        if added
          next_next_positions.concat(next_position.positions)
        end
      end
      next_positions = next_next_positions
    end
    return graph
  end

  def build_position(graph, position, taken_positions)
    added = false
    if !graph[position.id] and (!taken_positions[position.id] or taken_positions[position.id][:type] == 'ration' or graph.size == 0)
      graph[position.id] = {}
      graph[position.id]['id'] = position.id;
      graph[position.id]['area_id'] = position.area_id;
      graph[position.id]['order'] = position.order;
      graph[position.id]['centre_x'] = position.centre_x;
      graph[position.id]['centre_y'] = position.centre_y;
      graph[position.id]['links'] = {};
      position.positions.each do |next_position|
        graph[position.id]['links'][next_position.id] = next_position.id
      end
      graph[position.id]['rations'] = {};
      added = true

      # if the position is taken by a ration, add the ration to the list
      if taken_positions[position.id] && taken_positions[position.id][:type] == 'ration'
        ration = taken_positions[position.id]
        graph[position.id]['rations'][ration[:id]] = ration[:id]
      end
    end
    return added
  end

  def get_taken_positions
    taken_positions = Hash.new
    if @game
      rations = Ration.joins(:game_user).where(game_users: {game_id:@game.id})
      rations.each do |ration|
        taken_positions[ration.position.id] = {id: ration.id, type: 'ration'}
      end
      motiles = Motile.where(game: @game)
      motiles.each do |motile|
        taken_positions[motile.position.id] = {id: motile.id, type: 'motile'}
      end
    end
    return taken_positions
  end

  def load_game
    @game = Game.find(params[:game_id]) if params[:game_id]
  end
end
