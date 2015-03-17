class MovesController < ApplicationController
  before_filter :load_user

  def index
    @moves = move.all
    render :json => @moves.to_json(:include => [
      {ration: {:include => [:position]}},
      :game_user
    ])
  end

  def show
    @move = move.find(params[:id])
    render json: @move.to_json(:include => [
      {ration: {:include => [:position]}},
      :game_user
    ])
  end

  def update
    # do a check to calculate the dice, and if the 3rd dice is needed
    #if (params[:move][:ration_id] > 0 && )
    @move = move.find(params[:id])

    if params[:confirm_ration] and params[:ration_id]
      @move.ration_id = params[:ration_id]
      @move.save
      @move.set_dice

      render json: {
        success: true,
        move: @move.as_json,
        message: {title:'Ration Confirmed', text: 'The ration was selection was confirmed.', type:'success'}
      } and return
    end

    if params[:select_dice]
      @move.update(params.require(:move).permit(:selected_die))
      render json: {
        success: true,
        move: @move.as_json,
        message: {title:'Dice Confirmed', message: 'The dice was selection was confirmed.', type:'success'}
      } and return
    end

    render json: {
      success: false,
      move: @move.as_json,
      message: {title:'Move Not Made', message: 'No move was made, actions were not specified.', type:'warning'}
    } and return
  end

  private
  def load_user
    @game_user = GameUser.find(params[:game_user_id]) if params[:game_user_id]
    @round = Round.find(params[:round_id]) if params[:round_id]
    #@rations = @user ? @user.rations : Ration.scoped
  end

  def move
    @game_user ? @game_user.moves : (@round ? @round.moves : Move)
  end
end
