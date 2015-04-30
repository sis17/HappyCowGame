class RoundsController < ApplicationController
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :create]

  def index
    @rounds = Round.includes(:event, :moves).all
    render :json => @rounds.as_json
  end

  def show
    not_found and return if !Round.exists?(params[:id]) # return not found
    @round = Round.includes(:event, :moves).find(params[:id])
    render :json => @round.as_json
  end
end
