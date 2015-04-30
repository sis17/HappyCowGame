class CarddecksController < ApplicationController
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :create, :update, :destroy]

  def index
    @carddecks = Carddeck.all
    render :json => @carddecks.as_json
  end

  def show
    @carddeck = Carddeck.find(params[:id])
    render json: @carddeck.as_json
  end
end
