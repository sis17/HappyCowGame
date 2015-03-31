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
    messages = []
    success = false
    @move = move.find(params[:id])

    if params[:confirm_ration] and params[:ration_id]
      @move.ration_id = params[:ration_id]
      @move.save
      messages = @move.set_dice
      success = true
    elsif params[:make_move] and params[:move][:selected_die]
      ration = @move.ration
      if !@move.selected_die or @move.selected_die < 1
        messages = @move.select_dice(params[:move][:selected_die])
      end

      if params[:position_id]
        # update the ration position
        messages.concat(@move.confirm_move(params[:position_id]))
        success = true
      else
        messages.push({title:'Move Not Made', message: 'No position was specified.', type:'warning'})
      end
    else
      messages.push({title:'Move Not Made', message: 'No move was made, actions were not specified.', type:'warning'})
    end

    render json: {
      success: success,
      move: @move.as_json,
      messages: messages
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
