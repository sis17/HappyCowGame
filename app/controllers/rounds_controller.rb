class RoundsController < ApplicationController
  def index
    @rounds = Round.includes(:event, :moves).all
    render :json => @rounds.to_json(:include=>[
      :event,
      :moves
    ])
  end

  def show
    @round = Round.includes(:event, :moves).find(params[:id])
    render :json => @round.to_json(:include=>[
      :event,
      :moves
    ])
  end
end
