class CardsController < ApplicationController
  before_filter :load_user

  def index
    @cards = card.all
    render :json => @cards.as_json
  end

  def show
    @card = card.find(params[:id])
    render json: @card.as_json
  end

  def update
    if params[:game_user_id]
      @game_user_card = GameUserCard.find(params[:id])

      if params[:use]
        # do the use action
        response = @game_user_card.use #act_on_card(@game_user_card, params)

        render json: response and return
      end

      render json: {
        success: false,
        message: {title:'Card Not Changed', text: 'No valid action was specified for this card.', type:'warning'}
      } and return
    end

    render json: {
      success: false,
      message: {title:'Card Not Found', text: 'The card could not be updated', type:'warning'}
    } and return
  end

  private

  def load_user
    @game_user = GameUser.find(params[:game_user_id]) if params[:game_user_id]
    @game = Game.find(params[:game_id]) if params[:game_id]
    #@rations = @user ? @user.rations : Ration.scoped
  end

  def card
    @game_user ? @game_user.game_user_cards : (@game ? @game.game_cards : Card)
  end
end
