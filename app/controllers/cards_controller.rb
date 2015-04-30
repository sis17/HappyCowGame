class CardsController < ApplicationController
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :update, :destroy]
  before_filter :load_user

  def index
    @cards = card.all
    render :json => @cards.as_json
  end

  def show
    not_found and return if !card.exists?(params[:id])
    @card = card.find(params[:id])
    render json: @card.as_json
  end

  def update
    if params[:game_user_id]
      not_found and return if !GameUserCard.exists?(params[:id])
      @game_user_card = GameUserCard.find(params[:id])

      if params[:use]
        # do the use action
        card = @game_user_card.game_card.card
        game_user = @game_user_card.game_user
        response = @game_user_card.use

        if response[:success] and card.uri == 'medical_insurance'
          count = 0
          gucs = GameUserCard.where(game_user: game_user)
          while count < 4 and gucs[count]
            guc = gucs[count]
            GameUserCard.destroy(guc.id)
            count += 1
          end
          response[:message][:text] += ' 4 of your cards have been removed.'
        end

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

  def destroy

    if params[:game_user_id]
      not_found and return if !GameUserCard.exists?(params[:id])
      @card = GameUserCard.find(params[:id])
      action = Action.new
      action.set('Discarded a Card', "discarded the card #{@card.game_card.card.title}.",
        @card.game_user.game.round.id, @card.game_user.game.round.current_phase, @card.game_user.id
      )
      @card.destroy
      render json: {
        success: true,
        message: {title: 'Card Discarded', text:'', type:'success'}
      } and return
    end

    render json: {
      success: false,
      message: {title: 'Card Not Discarded', text:'You cannot discard that type of card.', type:'warning'}
    } and return
  end

  private

  def load_user
    @game_user = GameUser.find(params[:game_user_id]) if params[:game_user_id]
    unauthorised and return if params[:game_user_id] and @game_user.user_id != @user.id # check the user is the game user
    @game = Game.find(params[:game_id]) if params[:game_id]
    unauthorised and return if params[:game_id] and !@user.is_playing(@game) # check user is playing the game
  end

  def card
    @game_user ? @game_user.game_user_cards : (@game ? @game.game_cards : Card)
  end
end
