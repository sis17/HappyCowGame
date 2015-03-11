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
    @game = Game.find(params[:id])
    # do a check to see if the game is in the review phase, if so, allow update of round_id
    if params[:done_turn]
      # the user has finished doing what they can, move on to next turn, or phase, or round
      if @game.round.current_phase == 4
        #move on to the next turn
        round = Round.where(game_id: @game.id, number: @game.round.number+1).first
        if round
          @game.round = round
          @game.round.makeActive
          @game.save

          # each player needs 2 more cards
          @game.game_users.each do |game_user|
            assign_cards(@game, game_user, 2)
          end

          render :json => {success:true,
            message: {title:'Round Ended', text:'It is now '+@game.round.game_user.user.name+'`s turn.', type:'info'},
            round:@game.round.as_json
          } and return
        else
          #there are no more rounds!
          @game.stage = 2
          @game.save
          render :json => {success:false,
            message: {title:'The Game is Finished', text:'There are no more rounds.', type:'info'},
            round:@round.as_json
          } and return
        end
      else
        # get the next player, or move to the next phase
        @round = @game.round
        nextPlayer = get_next_player(@round, @round.game_user)
        messageText = ''
        if nextPlayer.id == @round.starting_user_id
          # if the phase has come back to the first player, move on the phase
          @round.current_phase = @round.current_phase+1
          messageText = ' the next phase, and '
        end
        @round.game_user = nextPlayer
        @round.save

        render :json => {success:true,
          message: {title:'Turn Ended', text:'It is now '+messageText+@round.game_user.user.name+'`s turn.', type:'info'},
          round:@round.as_json
        } and return
      end

    elsif !params[:begin] && @game.stage == 0
      # update a game, before it is formally created
      @game = Game.find(params[:id])
      # update the game details
      if params[:name]
        @game.name = params[:name]
      end
      if params[:carddeck_id]
        @game.carddeck_id = params[:carddeck_id]
      end
      if params[:rounds_min]
        @game.rounds_min = params[:rounds_min]
      end
      if params[:rounds_max]
        @game.rounds_max = params[:rounds_max]
      end
      #@game.update(params.require(:game).permit(:name, :carddeck_id, :rounds_min, :rounds_max))

      # update any new users
      if params[:users]
        params[:users].each do |user_id|
          create_game_user(@game, user_id)
        end
      end
      @game.save

    elsif params[:begin] && @game.stage == 0
      # formally create a game, move it to stage 1
      @game = Game.find(params[:id])
      @game.stage = 1

      #create the rounds
      game_user_offset = 0
      round_count = rand(@game.rounds_min..@game.rounds_max)
      round_num = 1
      while round_num <= round_count  do
        round = Round.new
        round.number = round_num
        round.event_id = Event.offset(rand(Event.count)).first.id
        round.current_phase = 2
        round.starting_user_id = GameUser.where({game_id: @game.id}).offset(game_user_offset).first.id
        round.game_user_id = round.starting_user_id
        round.game = @game
        round.save

        game_user_offset += 1
        if game_user_offset >= @game.game_users.count
          game_user_offset = 0;
        end
        round_num += 1

        #create moves within rounds
        @game.game_users.each do |game_user|
          move = Move.new
          move.game_user_id = game_user.id
          move.round_id = round.id
          move.save
        end
      end

      # set the last event as the slaughter house
      last_round = @game.rounds.last
      last_event = Event.where(category: 'end').first
      if last_round and last_event
        last_round.event_id = last_event.id
        last_round.save
      end

      #create the cards
      @game.carddeck.cards.each do |card|
        game_card = GameCard.new
        game_card.game = @game
        game_card.card = card
        game_card.quantity = if card.category == 'action' then 1 else 3 end
        game_card.save
      end

      #give cards to each player
      game_card_count = GameCard.where({game_id: params[:game_id]}).count - 1
      @game.game_users.each do |game_user|
        assign_cards(@game, game_user, 4)
      end

      #create the cow
      cow = Cow.new
      cow.ph_marker = 6.5
      cow.body_condition = 0
      cow.welfare = 0
      cow.oligos_marker = 0
      cow.muck_marker = 0
      cow.save
      @game.cow = cow

      create_ingredient_cats(@game)

      time = Time.new
      @game.start_time = time.strftime("%Y-%m-%d %H:%M:%S")
      @game.round = Round.where({game_id: @game.id}).first
      @game.save
    end

    render json: {
      success: true,
      game: @game.as_json,
      message: {title:'Game Save Succeeded', message:'The game was saved.', type:'success'}
    } and return
  end

  # POST /games.json
  def create
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

      render json: {
        success: true,
        game: @game.as_json,
        message: {title:'Game Initialised', text:'Now simply fill in information to get setup.', type:'success'}
      } and return
    end

    render json: {
      success: false,
      message: {title:'Game Initialisation Failed', text:'A creator and minimum game details were not provided.', type:'warning'}
    } and return
  end

  def destroy
    @game = Game.find(params[:id])
    @game.game_users.each do |game_user|
      game_user.destroy
    end
    name = @game.name
    @game.destroy
    render json: {
      success: true,
      message: {title:'Game Removed', text:'The game called `'+name+'` has been removed.', type:'success'}
    } and return
  end

  private
  def get_next_player(round, game_user)
    users = round.game.game_users

    currentUserIndex = false
    users.each_with_index do |user, index|
      if user.id == game_user.id
        currentUserIndex = index
      end
    end

    if users[currentUserIndex+1]
      return users[currentUserIndex+1]
    else
      return users[0]
    end
  end

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
