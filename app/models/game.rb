class Game < ActiveRecord::Base
  has_many :game_users
  has_many :users, through: :game_user
  has_many :users, foreign_key: 'creater_id'
  has_many :ingredient_cats
  has_many :rounds

  belongs_to :carddeck
  belongs_to :round
  belongs_to :round, foreign_key: "round_id"
  belongs_to :cow

  has_many :ingredient_cats

  def reset_ingredient_values
    # reset the values
    self.ingredient_cats.each do |ingredient_cat|
      if ingredient_cat.name == 'water'
        ingredient_cat.milk_score = 1
        ingredient_cat.meat_score = 1
        ingredient_cat.muck_score = 1
      elsif ingredient_cat.name == 'energy'
        ingredient_cat.milk_score = 6
        ingredient_cat.meat_score = 2
        ingredient_cat.muck_score = 1
      elsif ingredient_cat.name == 'protein'
        ingredient_cat.milk_score = 3
        ingredient_cat.meat_score = 4
        ingredient_cat.muck_score = 1
      elsif ingredient_cat.name == 'fiber'
        ingredient_cat.milk_score = 2
        ingredient_cat.meat_score = 2
        ingredient_cat.muck_score = 1
      elsif ingredient_cat.name == 'oligos'
        ingredient_cat.milk_score = self.cow.oligos_score
        ingredient_cat.meat_score = self.cow.oligos_score
        ingredient_cat.muck_score = 1
      end
      ingredient_cat.save
    end

    # change back any permanent changes
    #...
  end

  def finish_ration(ration)
    type = 'something'
    if ration.position_id == 78 # milk
      if self.cow.pregnancy_id > 0
        type = 'meat'
      else
        type = "milk"
      end
    end
    if ration.position_id == 86 # meat
      type = "meat"
    end
    if ration.position_id == 95 # muck
      type = "muck"
    end

    if type != 'something'
      score = 0
      ingredients = ''
      ration.ingredients.each do |ingredient|
        ingredients += "<span class='label #{ingredient.ingredient_cat.name}'>#{ingredient.ingredient_cat.name}</span>, "
        score += ingredient.ingredient_cat.get_score(type)
      end
      ration.game_user.score += score
      ration.game_user.save

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

  def assign_cards(game_user, number)
    game_card_count = GameCard.where({game_id: self.id}).count - 1
    while number > 0 do
        # get the card, and check that any cards exist
        game_card = GameCard.where({game_id: self.id}).offset(rand(0..game_card_count)).first
        if game_card
          game_user_card = GameUserCard.new
          game_user_card.game_card_id = game_card.id
          game_user_card.game_user_id = game_user.id
          game_user_card.save
        end
        number -= 1
    end
  end

  def as_json(options={})
    super(
      :include=> [
        {round: {:include => [:event,
          {game_user: {:include => [
            :user => {:only => [:id, :name, :experience]}
          ]}}
        ]}},
        :rounds,
        :carddeck,
        :cow,
        :ingredient_cats,
        {game_users: {:include => [
          :user => {:only => [:name]}
        ]}}
      ]
    )
  end
end
