class ActionsController < ApplicationController

  def index
    @actions = Action.all
    render json: @actions.as_json
  end

  def show
    @action = Action.find(params[:id])
    render json: @action.as_json
  end
end
