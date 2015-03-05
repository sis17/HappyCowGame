class PositionsController < ApplicationController
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
      #format.json  { render :json => @position, :methods => :graph(params[:depth].to_f)}
      render json: get_position(@position, params[:depth].to_f) and return #get_position(params[:id], params[:depth].to_f) and return
    end
    render :json => [] and return
  end

  private
  def get_position(position, depth)

    if depth > 0
      positions = []
      depth -= 1
      # get recursive positions
      position.positions.each do |pos|
        positions.push(get_position(pos, depth))
      end
      # attach the postions
      json = ActiveSupport::JSON.decode(position.to_json)
      json["positions"] = positions
      return json
    else
      return position
    end
  end
end
