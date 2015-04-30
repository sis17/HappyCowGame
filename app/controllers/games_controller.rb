class GamesController < ApplicationController
  # authenticate the following actions
  before_action :authenticate, only: [:index, :show, :create, :update, :destroy]

  def index
    @games = Game.all
    render json: @games.as_json
  end

  def show
    not_found and return if !Game.exists?(params[:id]) # return not found
    @game = Game.find(params[:id])
    unauthorised and return if !@user.is_playing(@game) # check user is authenticated
    render json: @game.as_json
  end

  def update
    not_found and return if !Game.exists?(params[:id]) # return not found if it doesn't exist
    messages = []
    success = false
    @game = Game.find(params[:id])
    unauthorised and return if !@user.is_playing(@game) # check user is authenticated

    # do a check to see if the game is in the review phase, if so, allow update of round_id
    if params[:done_turn]
      current_player = GameUser.find(@game.round.game_user_id)
      unauthorised and return if current_player.user_id != @user.id # check user is the current player

      # the user has finished doing what they can, move on to next turn, or phase, or round
      if @game.round.current_phase == 4
        #move on to the next round
        messages.concat(@game.finish_round)
        success = true
      else
        # get the next player, or move to the next phase
        @round = @game.round
        nextPlayer = @game.get_next_player
        messageText = ''

        @game.make_round_records # make the action if a movement round, and add round records for this round

        if nextPlayer.id == @round.starting_user_id
          # if the phase has come back to the first player, move on the phase
          @round.current_phase = @round.current_phase+1
          messageText = ' the next phase, and '
        end

        @round.game_user = nextPlayer
        @round.save

        success = true
        messages.push({
            title: 'Turn Ended', text: 'It is now '+messageText+@round.game_user.user.name+'`s turn.',
            type: 'info', time: 5
        })
      end

    elsif !params[:begin] && @game.stage == 0
      puts @game.user.name
      unauthorised and return if @game.user_id != @user.id # check user is game creator

      # update a game, before it is formally created
      @game = Game.find(params[:id])
      messages.push({
          title: 'Game Saved', text: 'The game has been successfully updated.', type: 'success', time: 4
      }) if @game.update(params.permit(:name, :carddeck_id, :rounds_min, :rounds_max))

      # update any new users
      if params[:users]
        params[:users].each do |user_id|
          game_user = @game.create_game_user(user_id)
          if game_user
            messages.push({
                title: 'User Added', text: 'The user '+game_user.user.name+' was added to the game.',
                type: 'success', time: 2
            })
          end
        end
      end

      @game.save
      success = true

    elsif params[:begin] && @game.stage == 0
      unauthorised and return if @game.user.id != @user.id # check user is game creator
      # formally create a game, move it to stage 1
      success = @game.begin

      if success
        messages.push({
            title: 'Game Begun',
            text: 'The game was successfully begun.',
            type: 'success', time: 2
        })
      else
        messages.push({
            title: 'Game Launch Failed',
            text: 'You cannot currently begin this game, sorry.',
            type: 'warning', time: 5
        })
      end
    end

    render json: {
      success: success,
      game: @game.as_json,
      messages: messages
    } and return
  end

  # POST /games.json
  def create
    messages = []
    success = false
    @game

    if params[:new] and params[:game] and (params[:user_id] or params[:users])
      @game = Game.new(params.require(:game).permit(:name, :carddeck_id, :rounds_min, :rounds_max))
      @game.stage = 0
      @game.rounds_min = 8 if !@game.rounds_min
      @game.rounds_max = 8 if !@game.rounds_max
      @game.carddeck_id = Carddeck.take.id if !@game.carddeck_id
      @game.save

      if params[:user_id] # for a single setup game
        @user = User.find(params[:user_id])
        @game.user_id = @user.id
        game_user = @game.create_game_user(@user.id)
        game_user.network = 0 # the creator shouldn't be set as network
        game_user.save
        @game.save
      end

      success = true
      messages.push({
        title:'Game Initialised', text:'Now simply fill in information to get setup.', type:'success', time: 4
      })
    else
      messages.push({
        title:'Game Initialisation Failed', text:'A creator and minimum game details were not provided.',
        type:'warning', time: 4
      })
    end

    render json: {
      success: success,
      game: @game.as_json,
      messages: messages
    } and return
  end

  def destroy
    not_found and return if !Game.exists?(params[:id]) # return not found

    messages = []
    success = false
    @game = Game.find(params[:id])
    unauthorised and return if @game.user_id != @user.id # check user is game creator

    if @game
      @game.game_users.each do |game_user|
        game_user.destroy
      end
      name = if @game.name.length > 0 then 'called `'+@game.name+'`' else 'with no name' end
      @game.destroy
      success = true
      messages.push({
        title:'Game Removed', text:'The game '+name+' has been removed.',
        type:'success', time: 2
      })
    else
      messages.push({
        title:'Game Not Removed', text:'We couldn`t find that game, you`ve probably already deleted it.',
        type:'warning', time: 4
      })
    end

    render json: {
      success: success,
      messages: messages
    } and return
  end

  private

  #def assign_cards(game, game_user, number)
  #  game_card_count = GameCard.where({game_id: game.id}).count - 1
  #  while number > 0 do
  #      # get the card, and check that any cards exist
  #      game_card = GameCard.where({game_id: game.id}).offset(rand(0..game_card_count)).first
  #      if game_card
  #        game_user_card = GameUserCard.new
  #        game_user_card.game_card_id = game_card.id
  #        game_user_card.game_user_id = game_user.id
  #        game_user_card.save
  #      end
  #      number -= 1
  #  end
  #end

  def create_ingredient_cats(game)
    ing_cat_water = IngredientCat.new(
      game: game, name: 'water',
      description: '+1 movement dice. Lowers PH in the Rumen if it exceeds energy.',
      milk_score: 1, meat_score: 1, muck_score: 1
    )
    ing_cat_water.save

    ing_cat_energy = IngredientCat.new(
      game: game, name: 'energy',
      description: 'Raises PH in the Rumen if it exceeds water. Scores high as milk.',
      milk_score: 6, meat_score: 2, muck_score: 1
    )
    ing_cat_energy.save

    ing_cat_protein = IngredientCat.new(
      game: game, name: 'protein', description: 'Scores adequately as milk, and best as meat.',
      milk_score: 3, meat_score: 4, muck_score: 1
    )
    ing_cat_protein.save

    ing_cat_fiber = IngredientCat.new(
      game: game, name: 'fiber', description: 'Allows pushing of rations with less fiber.',
      milk_score: 2, meat_score: 2, muck_score: 1
    )
    ing_cat_fiber.save

    ing_cat_oligos = IngredientCat.new(
      game: game, name: 'oligos', description: 'A special health booster. Scores very well the first time absorbed.',
      milk_score: 10, meat_score: 10, muck_score: 1
    )
    ing_cat_oligos.save
  end
end
