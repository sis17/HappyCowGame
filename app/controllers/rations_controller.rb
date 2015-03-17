class RationsController < ApplicationController
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

    #check if the ration is in the trough, to slide others down
    old_pos = @ration.position
    if old_pos.area_id == 1
      # slide all other rations down the trough
      @ration.game_user.game.game_users.each do |game_user|
        game_user.rations.each do |ration|
          if ration.position.area_id == 1 and ration.position.id != 1
            ration.position_id -= 1
            ration.save
          end
        end
      end
    end

    @ration.update(params.require(:ration).permit(:position_id))

    response = {ration: @ration}

    # consume the ration if on one of the meat, milk or muck squares
    pos = params[:ration][:position_id]
    if pos == 78 or pos == 86 or pos == 95
      response = @ration.game_user.game.finish_ration(@ration)
    end

    render json: response and return
  end

  def create
    @game_user = GameUser.find(params[:ration][:game_user_id])
    current_round = @game_user.game.round

    # check a ration hasn't already been created this round
    already_created_ration = Ration.where(game_user_id: @game_user.id, round_created_id: current_round.id).first
    if already_created_ration
      render json: {
        success: false,
        message: {title:'Ration Not Created', message: 'You can only create one ration a turn, you already created one earlier.', type:'warning'}
      } and return

    # check the user doesn't have too many rations already
    elsif @game_user.rations.count >= 4
      render json: {
        success: false,
        message: {title:'Ration Not Created', message: 'You have too many rations to create another.', type:'warning'}
      } and return

    # if passed above, create the ration
    elsif params[:ration] and params[:ration][:game_user_id]
      allowed = true
      @ration = Ration.new(params.require(:ration).permit(:game_user_id))
      @ration.round_created_id = current_round.id

      # find the first empty space in the trough
      pos = 1
      while pos <= 6
        existingRation = Ration.joins(:game_user).where(position_id: pos, game_users: {game_id:@game_user.game_id}).first
        if !existingRation
          @ration.position_id = pos
          pos = 6 # break out
        end
        pos += 1
      end

      if @ration.position_id > 0
        @ration.save
      else
        render json: {
            success: false,
            message: {title:'No Room in the Trough', message: 'Your ration could not be created, all the spaces in the trough are taken.', type:'success'}
        } and return
      end

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
    @game = Game.find(params[:game_id]) if params[:game_id]
    #@rations = @user ? @user.rations : Ration.scoped
  end

  def ration
    @game_user ? @game_user.rations : (@game ? Ration.joins(game_user: [:game]).where('game_users.game_id = ?', @game.id) : Ration)
  end
end
