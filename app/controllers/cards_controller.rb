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
        response = act_on_card(@game_user_card, params)

        render json: response and return
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
  def act_on_card(game_user_card, params)
    card = game_user_card.card
    success = false
    message = 'Default card message...'

    if card.title == 'Rumination'
      message = 'A random ration was moved back to the mouth.'
      game = game_user_card.game_user.game
#TODO - improve the randomness
      game_user_id = GameUser.where(game_id: game.id).first
      ration = Ration.where(game_user_id:game_user_id).first
      ration.position_id = 7
      ration.save
      success = true

    elsif card.title == 'Veterinarian'
      message = 'Welfare marker moved to 0.'
      cow = game_user_card.game_user.game.cow
      disease = Event.where(id: cow.disease_id).first
      if disease
        message += ' '+disease.title+' has been removed.'
      end

      cow.disease_id = nil
      cow.welfare = 0
      cow.save
      success = true
    end

    if success
      game_user_card.destroy
      return {
        success: true,
        message: {title:'Card Used', message: message, type:'success'}
      }
    else
      return {
        success: false,
        message: {title:'Card Used', message: 'The card could not be played, no condition exists for it.', type:'warning'}
      }
    end
  end

  def load_user
    @game_user = GameUser.find(params[:game_user_id]) if params[:game_user_id]
    @game = Game.find(params[:game_id]) if params[:game_id]
    #@rations = @user ? @user.rations : Ration.scoped
  end

  def card
    @game_user ? @game_user.game_user_cards : (@game ? @game.game_cards : Card)
  end
end
