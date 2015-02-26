class CardsController < ApplicationController
  before_filter :load_user

  def index
    @cards = card.all
    render :json => @cards.to_json(:include=>[
      :card
    ])
  end

  def show
    @card = card.find(params[:id])
    render json: @card.to_json(:include=>[
      :card
    ])
  end

  private
  def load_user
    @game_user = GameUser.find(params[:game_user_id]) if params[:game_user_id]
    @game = Game.find(params[:game_id]) if params[:game_id]
    #@rations = @user ? @user.rations : Ration.scoped
  end

  def card
    @game_user ? @game_user.game_cards : (@game ? @game.game_cards : Card)
  end
end
