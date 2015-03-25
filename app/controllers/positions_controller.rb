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
      taken_positions = get_taken_positions()
      #graph = get_position(@position, params[:depth].to_f, taken_positions
      graph = Hash.new
      build_graph(graph, @position, params[:depth].to_f, taken_positions)
      render json: graph and return
      #render json: get_position(@position, params[:depth].to_f) and return #get_position(params[:id], params[:depth].to_f) and return
    end
    render :json => [] and return
  end

  private

  def build_graph(graph, position, depth, taken_positions)
    depth -= 1
    # create the position, if not already there
    if !graph[position.id]
      graph[position.id] = {}
      graph[position.id]['id'] = position.id;
      graph[position.id]['area_id'] = position.area_id;
      graph[position.id]['order'] = position.order;
      graph[position.id]['centre_x'] = position.centre_x;
      graph[position.id]['centre_y'] = position.centre_y;
      graph[position.id]['links'] = {};
    end

    # add any links
    if depth >= 1 and position.positions
      position.positions.each do |pos|
        if !taken_positions[pos.id]
          # add the links to the current position
          graph[position.id]['links'][pos.id] = pos.id;
          # add the next position, if it doesn't already exist
          build_graph(graph, pos, depth, taken_positions)
        end
      end
    end
  end

  def get_position(position, depth, taken_positions)
    # set this position as visited
    depth -= 1
    if depth >= 1
      positions = []
      # get recursive positions
      position.positions.each do |pos|
        if !taken_positions[pos.id]
          positions.push(get_position(pos, depth, taken_positions))
        end
      end

      # attach the postions
      json = ActiveSupport::JSON.decode(position.to_json)
      json[:depth] = depth
      json["positions"] = positions
      return json
    else
      pos = ActiveSupport::JSON.decode(position.to_json)#position
      pos[:depth] = depth
      return pos
    end
  end

  def get_taken_positions
    taken_positions = Hash.new
    if @game
      rations = Ration.joins(:game_user).where(game_users: {game_id:@game.id})
      rations.each do |ration|
        taken_positions[ration.position.id] = ration.position.id
      end
      motiles = Motile.where(game_id: @game.id)
      motiles.each do |motile|
        taken_positions[motile.position.id] = motile.position.id
      end
    end
    return taken_positions
  end

  def load_game
    @game = Game.find(params[:game_id]) if params[:game_id]
  end
end
