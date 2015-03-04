class CarddecksController < ApplicationController

  def index
    @carddecks = Carddeck.all
    render :json => @carddecks.as_json
  end

  def show
    @carddeck = Carddeck.find(params[:id])
    render json: @carddeck.as_json
  end
end
