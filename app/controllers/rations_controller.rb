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

  def create
    @game_user = GameUser.find(params[:ration][:game_user_id])

    if @game_user.rations.count >= 4
      render json: {
        success: false,
        message: {title:'Ration Not Created', message: 'You have too many rations to create another.', type:'warning'}
      } and return
    elsif params[:ration] and params[:ration][:game_user_id]
      allowed = true
      @ration = Ration.new(params.require(:ration).permit(:game_user_id))
      @ration.position_id = 1
      @ration.save

      params[:ration][:ingredients].each do |ing|
        puts ing
        if ing[:id]
          @card = GameUserCard.find(ing[:id])
          @ingredient_cat = IngredientCat.where({name: @card.game_card.card.category, game_id: @game_user.game.id}).first
          puts @ingredient_cat
          if @ingredient_cat
            @card.destroy
            @ingredient = Ingredient.new({ration_id: @ration.id, ingredient_cat_id: @ingredient_cat.id})
            @ingredient.save
          end
        end
      end

      render json: {
          success: true,
          message: {title:'Ration Created', message: 'Your ration was created.', type:'success'}
      } and return
    end

    render json: {
      success: true,
      message: {title:'Ration Not Created', message: 'Not enough ration details were specified.', type:'warning'}
    } and return
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
