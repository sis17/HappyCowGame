class RationsController < ApplicationController
  before_filter :load_user

  def index
    @rations = ration.includes({game_user: :user}, {ingredients: :ingredient_cat}, :position, :moves).all
    render :json => @rations
  end

  def show
    @ration = ration.includes({game_user: :user}, {ingredients: :ingredient_cat}, :position, :moves).find(params[:id])
    render json: @ration
  end

  def update
    @ration = Ration.find(params[:id])
    @ration.update(params.require(:ration).permit(:position_id))

    render json: @ration
  end

  private
  def load_user
    @game_user = GameUser.find(params[:game_user_id]) if params[:game_user_id]
    #@game = Game.find(params[:game_id]) if params[:game_id]
    #@rations = @user ? @user.rations : Ration.scoped
  end

  def ration
    @game_user ? @game_user.rations : Ration
  end
end
