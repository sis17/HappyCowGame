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
      render :json => getPosition(params[:id], params[:depth]) and return
    end
    render :json => [] and return
  end

  private
  def getPosition(position_id, depth)
    if depth > 0
      @position = Position.find(position_id)
      json = @postion.as_json
      positions = []
      json.postions.each do |pos|
        positions.push(getPosition(pos.id, --depth))
      end
      json.positions = positions
      return json
    else
      return {}
    end
  end
end
