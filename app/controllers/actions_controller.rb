class ActionsController < ApplicationController
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :create, :update, :destroy]
  
  def index
    @actions = Action.all
    render json: @actions.as_json
  end

  def show
    @action = Action.find(params[:id])
    render json: @action.as_json
  end
end
