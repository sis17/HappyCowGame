class GameUser < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_id"
  belongs_to :game, :foreign_key => "game_id"

  has_many :rounds

  has_many :game_user_cards
  has_many :game_cards, :through => :game_user_cards

  has_many :rations
  has_many :moves
  has_many :actions

  def make_ration(ration_params)
    messages = []
    ration = Ration.new
    ration.game_user_id = self.id
    ration.round_created_id = self.game.round.id

    # find the first empty space in the trough
    pos = 1
    while pos <= 6
      existingRation = Ration.joins(:game_user).where(position_id: pos, game_users: {game_id:self.game_id}).first
      if !existingRation
        ration.position_id = pos
        pos = 6 # break out
      end
      pos += 1
    end

    # check there is space for the ration
    if ration.position_id < 0
      messages.push({
        title:'No Room in the Trough', text: 'Your ration could not be created, all the spaces in the trough are taken.',
        type:'success', time: 5
      })
      return {success: false, messages: messages}
    end

    #check the user has cards
    if ration_params[:ingredients].length <= 0
      messages.push({
        title:'You Need Ingredients', text: 'You must use at least one ingredient to create a ration, you submitted none.',
        type:'warning', time: 5
      })
      return {success: false, messages: messages}
    end

    ration.save

    #tansfer cards to ingredients
    cards = []
    ration_params[:ingredients].each do |ing|
      if ing[:id]
        card = GameUserCard.find(ing[:id])
        cards.push(card)
        ingredient_cat = IngredientCat.where({name: card.game_card.card.category, game_id: self.game.id}).first
        if self.game.cow.check_mad and ingredient_cat.name == 'protein' # if the mad cow disease is in action
          ration.destroy # remove the ration again
          messages.push({
            title:'Illegal Protein', text: 'During the Mad Cow Crisis you cannot play protein cards. Your ration was not created.',
            type:'danger', time: 6
          })
          return {success: false, messages: messages}
        elsif ingredient_cat
          ingredient = Ingredient.new({ration_id: ration.id, ingredient_cat_id: ingredient_cat.id})
          ingredient.save
        else
          # an ingredient was not found
          ration.destroy # remove the ration again
          messages.push({
            title:'Missing Ingredient', text: 'Your ration could not be created because an ingredient you submitted could not be found in your hand.',
            type:'warning', time: 6
          })
          return {success: false, messages: messages}
        end
      end
    end

      # we're still here, so all good so far, remove the cards
      cards.each do |card|
        card.destroy
      end

      # create an action to mark the event
      action = Action.new
      action.set('Created a Ration', 'They created a ration with '+ration.describe_ingredients+'.',
        ration.game_user.game.round_id, 2, ration.game_user.id
      )

      messages.push({
        title:'Ration Created', text: 'Your ration was created with '+ration.describe_ingredients+'.',
        type:'success', time: 6
      })

    return {success: true, messages: messages}
  end

  def as_json(options={})
    super(
      :include=> [
        {game: {:include => [
          {round: {:include => [
            {game_user: {:include => [:user  => {:only => [:id, :name]}]}}
          ]}},
          :cow,
          :game_users
        ]}},
        :rations,
        :game_cards,
        :user => {:only => [:name]}
      ]
    )
  end
end
