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

  def update
    if params[:game_user_id]
      @game_user_card = card.find(params[:id])

      if params[:use]
        # do the use action
        @game_user_card.destroy
        render json: {
          success: true,
          message: {title:'Card Used', message: 'Your card has been used.', type:'success'}
        } and return
      end

      render json: {
        success: false,
        message: {title:'Card Not Changed', message: 'No valid action was specified for this card.', type:'warning'}
      } and return
    end

    render json: {
      success: false,
      message: {title:'Card Not Found', message: 'The card could not be updated', type:'warning'}
    } and return
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
