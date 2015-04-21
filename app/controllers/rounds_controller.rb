class RoundsController < ApplicationController
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :create]

  def index
    @rounds = Round.includes(:event, :moves).all
    render :json => @rounds.as_json
  end

  def show
    @round = Round.includes(:event, :moves).find(params[:id])
    render :json => @round.as_json
  end

  # changes the current player and current phase
  def create
    if params[:game_user_id] and params[:round_id]
      # completing a round
      @game_user = GameUser.find(params[:game_user_id])
      @round = Round.find(params[:round_id])
      if params[:complete]
        # the user is finished with the round

        #TODO
      elsif params[:phase_complete]
        # the user is finished with their phase, move to the next player
        nextPlayer = get_next_player(@round, @game_user)
        if nextPlayer.id == @round.starting_user_id
          # if the phase has come back to the first player, move on the phase
          @round.current_phase = @round.current_phase+1
        end
        @round.game_user = nextPlayer
        @round.save
        render :json => {success:true,
          message: {title:'Turn Ended', message:'It is now '+@round.game_user.user.name+'\s turn.', type:'info'},
          round:@round.as_json} and return
      end
    else
      # do a normal create
      #render :json => {success:true, round:@round.as_json} and return
    end

    render :json => {success:false,
      message: {title:'Round Not Changed', message:'A post was done to rounds/ with no data', type:'warning'}
    } and return
  end

  private
  def get_next_player(round, game_user)
    users = round.game.game_users
    nextUserId = game_user.id+1
    nextUser = false
    users.each do |user|
      if user.id == nextUserId
        nextUser = user
      end
    end

    if !nextUser
      nextUser = users.first
    end

    nextUser
  end
end
