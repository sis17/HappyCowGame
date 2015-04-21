class RationsController < ApplicationController
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :create, :update]
  before_filter :load_user

  def index
    @rations = ration.includes({game_user: :user}, {ingredients: :ingredient_cat}, :position, :moves).all
    render json: @rations
  end

  def show
    @ration = ration.includes({game_user: :user}, {ingredients: :ingredient_cat}, :position, :moves).find(params[:id])
    render json: @ration
  end

  def update
    @ration = Ration.find(params[:id])
    # actions done in the move_controller
    render json: response and return
  end

  def create
    success = false
    messages = []
    @game_user = GameUser.find(params[:ration][:game_user_id])
    current_round = @game_user.game.round

    # check a ration hasn't already been created this round
    already_created_ration = Ration.where(game_user_id: @game_user.id, round_created_id: current_round.id).first
    if already_created_ration
      messages.push({
        title:'Ration Not Created', text: 'You can only create one ration a turn, you already created one earlier.',
        type:'warning', time:4
      })

    # check the user doesn't have too many rations already
    elsif @game_user.rations.count >= 4
      messages.push({
        title:'Ration Not Created', text: 'You have too many rations to create another.', type:'warning', time: 4
      })

    # if passed above, create the ration
    elsif params[:ration] and params[:ration][:game_user_id]
      allowed = true
      response = @game_user.make_ration(params[:ration][:ingredients])
      render json: response and return
    else
      messages.push({
        title:'Ration Not Created', text: 'Not enough ration details were specified.',
        type: 'warning', time: 4
      })
    end

    render json: {
      success: success,
      messages: messages
    } and return
  end

  private
  def load_user
    @game_user = GameUser.find(params[:game_user_id]) if params[:game_user_id]
    @game = Game.find(params[:game_id]) if params[:game_id]
    #@rations = @user ? @user.rations : Ration.scoped
  end

  def ration
    @game_user ? @game_user.rations : (@game ? Ration.joins(game_user: [:game]).where('game_users.game_id = ?', @game.id) : Ration)
  end
end
