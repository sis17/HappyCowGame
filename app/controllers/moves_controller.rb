class MovesController < ApplicationController
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :update]
  before_filter :load_user

  def index
    @moves = move.all
    render :json => @moves.to_json(:include => [
      {ration: {:include => [:position]}},
      :game_user
    ])
  end

  def show
    not_found and return if !move.exists?(params[:id])
    @move = move.find(params[:id])
    render json: @move.to_json(:include => [
      {ration: {:include => [:position]}},
      :game_user
    ])
  end

  def update
    messages = []
    success = false
    not_found and return if !move.exists?(params[:id])
    @move = move.find(params[:id])
    unauthorised and return if @move.game_user.user_id != @user.id # check the user is the game user

    # when the player has selected a ration, and wishes to begin moving it,
    # they must confirm it so that dice can be generated and assigned
    if params[:confirm_ration] and params[:ration_id]
      if @move.ration_id # check that a ration has not already been set
        messages.push({title:"Ration Already Selected", text:"You have already confirmed a raiton this turn.", type:"warning", time:6})
      elsif !Ration.exists?(params[:ration_id])
        messages.push({title:"Ration Not Found", text:"The ration you attempted to confirm could not be found by the system.", type:"warning", time:6})
      else
        ration = Ration.find(params[:ration_id])
        if ration.game_user.user_id != @user.id # check that the owner of the ration is the authorised user
          messages.push({title:"Ration Not Yours", text:"The ration you attempted to confirm does not belong to you.", type:"warning", time:6})
        else
          @move.ration = ration
          @move.save
          messages = @move.set_dice
          success = true
        end
      end

    # when the player has chosen a dice, they click to move the ration.
    # the chosen dice is confirmed on the first move, after that the ration is simply moved
  elsif params[:make_move] and params[:move] and params[:move][:selected_die]
      if !@move.ration_id
        messages.push({title:'Choose a Ration', message: 'You must choose a ration before you can move.', type:'warning', time:6})
      else
        ration = @move.ration
        if !@move.selected_die or @move.selected_die < 1
          messages = @move.select_dice(params[:move][:selected_die].to_i)
        end

        if params[:position_id]
          # update the ration position
          is_end_position = false
          is_end_position = true if params[:all_moves]
          response = @move.confirm_move(params[:position_id], is_end_position) # second parameter to determine if it's a final move
          success = response[:success]
          messages.concat(response[:messages])
        else
          messages.push({title:'Move Not Made', message: 'No position was specified.', type:'warning'})
        end
      end

    # only one of the two above actions are allowed
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
  def load_user # loads the correct model for nested resources
    @game_user = GameUser.find(params[:game_user_id]) if params[:game_user_id]
    unauthorised and return if params[:game_user_id] and @game_user.user_id != @user.id # check the user is the game user
    @round = Round.find(params[:round_id]) if params[:round_id]
    unauthorised and return if params[:round_id] and !@user.is_playing(@round.game) # check user is playing the game
  end

  def move
    @game_user ? @game_user.moves : (@round ? @round.moves : Move)
  end
end
