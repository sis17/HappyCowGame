class Game < ActiveRecord::Base
  has_many :game_users
  has_many :users, through: :game_user
  has_many :users, foreign_key: 'creater_id'
  has_many :ingredient_cats
  has_many :rounds
  has_many :motiles
  has_many :game_cards
  has_many :ingredient_cats

  belongs_to :carddeck
  belongs_to :round
  belongs_to :round, foreign_key: "round_id"
  belongs_to :cow

  def begin
    # check it's in the right phase
    return false if self.stage != 0

    #create the rounds
    game_user_offset = 0
    round_count = rand(self.rounds_min..self.rounds_max)
    round_num = 1
    while round_num <= round_count  do
      round = Round.new
      round.number = round_num
      event_id = Event.offset(rand(Event.count)).first.id
      if event_id != 8 then round.event_id = event_id else round.event_id = 7 end
      round.current_phase = 2
      round.starting_user_id = GameUser.where({game_id: self.id}).offset(game_user_offset).first.id
      round.game_user_id = round.starting_user_id
      round.game = self
      round.save

      game_user_offset += 1
      if game_user_offset >= self.game_users.count
        game_user_offset = 0;
      end
      round_num += 1

      #create moves within rounds
      self.game_users.each do |game_user|
        Move.new(game_user_id: game_user.id, round_id: round.id).save
      end
    end

    # set the last event as the slaughter house
    last_round = self.rounds.last
    last_event = Event.where(category: 'end').first
    if last_round and last_event
      last_round.event_id = last_event.id
      last_round.save
    end

    #create 3 motile pieces
    count = 3
    while count > 0 do
      position_id = Position.where(area_id:3).offset(rand(Position.where(area_id:3).count)).first.id
      Motile.new(game_id: self.id, position_id: position_id).save
      count -= 1
    end

    #create the cards
    self.carddeck.cards.each do |card|
      GameCard.new(game: self, card: card).save
    end

    #give cards to each player
    self.game_users.each do |game_user|
      self.assign_cards(game_user, 4)
    end

    #create the cow
    Cow.new(game: self).save

    # create ingredient cats
    IngredientCat.new(
      game: self, name: 'water',
      description: '+1 movement dice. Lowers PH in the Rumen if it exceeds energy.',
      milk_score: 1, meat_score: 1, muck_score: 1
    ).save

    IngredientCat.new(
      game: self, name: 'energy',
      description: 'Raises PH in the Rumen if it exceeds water. Scores high as milk.',
      milk_score: 6, meat_score: 2, muck_score: 1
    ).save

    IngredientCat.new(
      game: self, name: 'protein', description: 'Scores adequately as milk, and best as meat.',
      milk_score: 3, meat_score: 4, muck_score: 1
    ).save

    IngredientCat.new(
      game: self, name: 'fiber', description: 'Allows pushing of rations with less fiber.',
      milk_score: 2, meat_score: 2, muck_score: 1
    ).save

    IngredientCat.new(
      game: self, name: 'oligos', description: 'A special health booster. Scores very well the first time absorbed.',
      milk_score: 10, meat_score: 10, muck_score: 1
    ).save

    #time = Time.new
    self.start_time = Time.new.strftime("%Y-%m-%d %H:%M:%S")
    self.round = Round.where({game: self}).order(:number).first

    self.stage = 1
    self.save
    return true
  end

  def get_next_player
    currentUserIndex = false
    self.game_users.each_with_index do |user, index|
      currentUserIndex = index if user.id == self.round.game_user.id
    end

    return self.game_users[currentUserIndex+1] if self.game_users[currentUserIndex+1]
    return self.game_users[0]
  end

  def finish_ration(ration)
    type = 'something'
    if ration.position_id == 78 # milk
      if !self.cow.pregnancy_id then type = 'milk' else type = "meat" end
    end
    if ration.position_id == 86 then type = "meat" end
    if ration.position_id == 95 then type = "muck" end

    if type != 'something'
      score = 0
      ration.ingredients.each do |ingredient|
        score += ingredient.ingredient_cat.get_score(type)
        self.cow.increase_oligos_marker(1) if ingredient.ingredient_cat.name == 'oligos' and type != 'muck' # increase amount of oligos
      end
      score -= 1 if self.cow.check_cold # -1 point for rations absorbed when it's cold
      ration.game_user.score += score
      ration.game_user.save

      action = Action.new
      action.set('Ration Absorbed', 'Their ration was absorbed as '+type+', and gained '+score.to_s+' points for '+ration.describe_ingredients+'.',
        self.round_id, 3, ration.game_user.id
      )

      ingredients = ration.describe_ingredients
      ration.destroy

      return {
        success: true,
        ration: nil,
        message: {
          title: 'Ration Consumed',
          text: "Your ration was consumed as #{type}, you gained #{score} points for: #{ingredients}",
          type: 'success'
        }
      }
    end

    return {
      success: false,
      ration: ration,
      message: {
        title: 'Ration Not Consumed',
        text: "Your ration could not be consumed, we didn`t recognise what it is being consumed as.",
        type: 'warning'
      }
    }
  end

  def arrange_trough(starting_pos)
    if starting_pos.area_id == 1
      # slide all other rations down the trough
      self.game_users.each do |game_user|
        game_user.rations.each do |ration|
          if ration.position.area_id == 1 and ration.position.order != 1
            ration.position = Position.find_by(order: ration.position.order - 1)
            ration.save
          end
        end
      end
    end

    if self.cow.check_hot
      self.sort_trough('water')
    end
  end

  def sort_trough(type)
    # get rations that are in the trough, in order
    rations = Ration.joins(:game_user).joins(:position)
      .where('game_users.game_id = ? and positions.area_id = 1', self.id)
      .order('"positions"."order" ASC')
    j = 0
    while j < rations.length do
      i = j+1
      greatest = rations[j].count_type(type)
      greatest_pos = j
      while rations[i] do
        count = rations[i].count_type(type)
        if count > greatest
          greatest = count
          greatest_pos = i
        end
        i += 1
      end
      if (greatest_pos != j) #switch
        temp_pos = rations[j]
        rations[j] = rations[greatest_pos]
        rations[greatest_pos] = temp_pos
      end
      rations[j].position = Position.find_by(order: j+1)
      rations[j].save
      j += 1
    end
  end

  def assign_cards(game_user, number)
    # assemble the right proportion of card ids in a balance
    actions = GameCard.joins(:card).where("cards.category = 'action'").all.shuffle[1..self.card_balance('action')]
    ingredients = GameCard.joins(:card).where("cards.category != 'action'").all.shuffle[1..self.card_balance('ingredient')]
    game_card_ids = []
    puts "action pick: "+actions.length.to_s
    puts "ingredient pick: "+ingredients.length.to_s
    actions.each do |game_card|
      game_card_ids.push(game_card.id)
    end
    ingredients.each do |game_card|
      game_card_ids.push(game_card.id)
    end
    puts "together pick: "+game_card_ids.length.to_s
    while number > 0 do
        game_user_card = GameUserCard.new
        game_user_card.game_card_id = game_card_ids[rand(0..game_card_ids.length-1)]
        puts "chosen id: "+game_user_card.game_card_id.to_s
        game_user_card.game_user_id = game_user.id
        game_user_card.save

        number -= 1
    end
  end

  def card_balance(type)
    round_percent = 0.1
    round_percent = self.round.number / self.rounds.length if self.rounds.length > 0 and self.round
    if type == 'action'
      return 4 if round_percent > 0.75
      return 2 if round_percent > 0.5
      return 1
    elsif type == 'ingredient'
      return 0 if round_percent > 0.75
      return 2 if round_percent > 0.5
      return 3
    end
    return 0
  end

  def finish
    if self.stage == 1
      self.stage = 2
      # give every player a bit of experience
      score = 0
      winner = nil
      self.game_users.each do |game_user|
        game_user.user.experience += 1
        game_user.user.save
      end

      # if there is a winner, and more than one player, give them a bonus
      game_users = GameUser.where(game: self).order(score: :desc)
      if game_users.length > 1 and game_users[0].score > game_users[1].score
        user = game_users[0].user
        user.experience += 2
        user.save
      end

      self.save
    end
  end

  def as_json(options={})
    super(
      :include=> [
        {round: {:include => [:event,
          {game_user: {:include => [
            :user => {:only => [:id, :name, :experience]}
          ]}},
          {actions: {:include => [
            {game_user: {:include => [
              :user => {:only => [:id, :name]}
            ]}}
          ]}}
        ]}},
        :rounds,
        :carddeck,
        :cow,
        {motiles: {:include => [
          :position
        ]}},
        :ingredient_cats,
        {game_users: {include: [
          {rations: {include: [
            {ingredients: {include: [:ingredient_cat]}},
            :position
          ]}},
          user: {only: [:name]}
        ]}}
      ]
    )
  end
end
