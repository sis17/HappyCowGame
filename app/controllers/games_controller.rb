class GamesController < ApplicationController
  def index
    @games = Game.all
    render json: @games.as_json
  end

  def show
    @game = Game.find(params[:id])
    render json: @game.as_json
  end

  def update
    messages = []
    success = false
    @game = Game.find(params[:id])

    # do a check to see if the game is in the review phase, if so, allow update of round_id
    if params[:done_turn]
      # the user has finished doing what they can, move on to next turn, or phase, or round
      if @game.round.current_phase == 4
        #move on to the next turn
        round = Round.where(game_id: @game.id, number: @game.round.number+1).first
        if round
          @game.cow.turn_effects
          # move the motiles
          @game.motiles.each do |motile|
            messages.concat(motile.move)
          end

          @game.round = round
          @game.round.makeActive
          @game.save

          # each player needs 2 more cards
          @game.game_users.each do |game_user|
            assign_cards(@game, game_user, 2)
          end

          success = true
          messages.push({
              title: 'Round Finished',
              text: 'It is Round '+@game.round.number.to_s+', and is now '+@game.round.game_user.user.name+'`s turn.',
              type: 'info', time: 5
          })
        else
          #there are no more rounds!
          @game.finish
          success = false
          messages.push({
              title: 'Game Finished', text: 'There are no more rounds.',
              type: 'info', time: 5
          })
        end
      else
        # get the next player, or move to the next phase
        @round = @game.round
        nextPlayer = @game.get_next_player
        messageText = ''
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
      # update a game, before it is formally created
      @game = Game.find(params[:id])
      # update the game details
      if params[:name]
        @game.name = params[:name]
        messages.push({
            title: 'Game Changed', text: 'The game name was changed to '+@game.name+'.',
            type: 'success', time: 2
        })
      end
      if params[:carddeck_id]
        carddeck = CardDeck.find(params[:carddeck_id])
        if carddeck
          @game.carddeck_id = params[:carddeck_id]
          messages.push({
              title: 'Game Changed', text: 'The game card deck was changed to '+carddeck.name+'.',
              type: 'success', time: 2
          })
        end
      end
      if params[:rounds_min]
        @game.rounds_min = params[:rounds_min]
        messages.push({
            title: 'Game Changed', text: "The minimum number of rounds was changed to #{@game.rounds_max.to_s}.",
            type: 'success', time: 2
        })
      end
      if params[:rounds_max]
        @game.rounds_max = params[:rounds_max]
        messages.push({
            title: 'Game Changed', text: "The maximum number of rounds was changed to #{@game.rounds_max.to_s}.",
            type: 'success', time: 2
        })
      end
      #@game.update(params.require(:game).permit(:name, :carddeck_id, :rounds_min, :rounds_max))

      # update any new users
      if params[:users]
        params[:users].each do |user_id|
          game_user = GameUser.find(user_id)
          create_game_user(@game, user_id)
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
      # formally create a game, move it to stage 1
      @game = Game.find(params[:id])
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
    @user = User.find(params[:user_id])

    if params[:new] and params[:game] and @user
      @game = Game.new(params.require(:game).permit(:name, :carddeck_id, :rounds_min, :rounds_max))
      @game.stage = 0
      @game.rounds_min = 8
      @game.rounds_max = 8
      @game.creater_id = @user.id
      @game.save

      #params[:users].each do |user_id|
      create_game_user(@game, @user.id)
      #end

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
    messages = []
    success = false
    @game = Game.find(params[:id])
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

  def assign_cards(game, game_user, number)
    game_card_count = GameCard.where({game_id: game.id}).count - 1
    while number > 0 do
        # get the card, and check that any cards exist
        game_card = GameCard.where({game_id: game.id}).offset(rand(0..game_card_count)).first
        if game_card
          game_user_card = GameUserCard.new
          game_user_card.game_card_id = game_card.id
          game_user_card.game_user_id = game_user.id
          game_user_card.save
        end
        number -= 1
    end
  end

  def create_game_user(game, user_id)
    user = User.find(user_id)
    game_user = GameUser.where({game_id: game.id, user_id: user_id}).first
    if !game_user
      game_user = GameUser.new()
      game_user.user = user
      game_user.game = game
      game_user.colour = user.colour
      game_user.score = 0
      game_user.save
    end
    game_user
  end

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
