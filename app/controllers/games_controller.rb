class GamesController < ApplicationController
  def index
    @games = Game.all
    render :json => @games.as_json
  end

  def show
    #@game = Game.find(params[:id])
    #@gameuser = GameUser.where({game_id: @game.id}).offset(0).first
    #render :json => @gameuser
    @game = Game.find(params[:id])
    render :json => @game.as_json
  end

  def update
    @game = Game.find(params[:id])
    # do a check to see if the game is in the review phase, if so, allow update of round_id
    if params[:next_turn] && @game.round.current_phase == 4
      @game.round_id += 1
      @game.save

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
        round.event = Event.offset(rand(Event.count)).first
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
      game_card_count = GameCard.count
      @game.game_users.each do |game_user|
        card_count = 0
        while card_count < 4 do
          game_card = GameCard.where({game_id: @game.id}).offset(rand(game_card_count)).first
          game_user_card = GameUserCard.new(game_card: game_card, game_user: game_user)
          game_user_card.save
          card_count += 1
        end
      end

      #create the cow
      cow = Cow.new
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

    if params[:new] && params[:game]
      @game = Game.new(params.require(:game).permit(:name, :carddeck_id, :rounds_min, :rounds_max))
      @game.stage = 0
      @game.save

      params[:users].each do |user_id|
        create_game_user(@game, user_id)
      end

      render json: {
        success: true,
        game: @game.as_json,
        message: {title:'Game Save Succeeded', message:'The game was saved.', type:'success'}
      } and return
    end
  end

  private
  def create_game_user(game, user_id)
    user = User.find(user_id)
    game_user = GameUser.where({game_id: game.id, user_id: user_id}).first
    if !game_user
      game_user = GameUser.new()
      game_user.user = user
      game_user.game = game
      game_user.colour = user.colour
      game_user.save
    end
    game_user
  end

  def create_ingredient_cats(game)
    ing_cat_water = IngredientCat.new(game: game, name: 'water', description: '+1 movement dice. Lowers PH in the Rumen if it exceeds energy.')
    ing_cat_water.save

    ing_cat_energy = IngredientCat.new(game: game, name: 'energy', description: 'Raises PH in the Rumen if it exceeds water. Scores high as milk.')
    ing_cat_energy.save

    ing_cat_protein = IngredientCat.new(game: game, name: 'protein', description: 'Scores adequately as milk, and best as meat.')
    ing_cat_protein.save

    ing_cat_fiber = IngredientCat.new(game: game, name: 'fiber', description: 'Allows pushing of rations with less fiber.')
    ing_cat_fiber.save

    ing_cat_oligos = IngredientCat.new(game: game, name: 'oligos', description: 'A special health booster. Scores very well the first time absorbed.')
    ing_cat_oligos.save
  end
end
