class EventsController < ApplicationController
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :create, :update, :destroy]

  def index
    @events = Event.all
    render json: @events.as_json
  end

  def show
    @event = Event.find(params[:id])
    render json: @event.as_json
  end
end
