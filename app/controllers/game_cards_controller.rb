class GameCardsController < ApplicationController
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :create, :update, :destroy]

  def index
    @game_cards =  GameCard.where({game_id: params[:game_id]}).all
    render json: @game_cards.as_json
  end

  def show
    @game_card = GameCard.find(params[:id])
    render json: @game_card.as_json
  end
end
