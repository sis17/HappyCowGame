class Move < ActiveRecord::Base
  belongs_to :game_user
  belongs_to :round
  belongs_to :ration

  def set_dice
    # check if the ration is in the intestine (for constipation)
    if self.round.game.cow.check_constipated and self.ration.position.area_id == 4
      self.dice1 = rand(1..3) # small movements
    elsif self.round.game.cow.check_diarrhea and self.ration.position.area_id == 4
      self.dice1 = rand(5..6) # fast movements
    else
      self.dice1 = rand(1..6)
      self.dice2 = rand(1..6)
      self.add_water
    end
    self.save
  end

  def select_dice(dieNum)
    # check for water, and diseases
    self.selected_die = dieNum
    self.save
    return {
      success: true,
      move: self.as_json,
      messages: [{title:'Dice Confirmed', message: 'The dice was selection was confirmed.', type:'success'}]
    }
  end

  def add_water
    if self.ration_id
      has_water = Ration.joins(ingredients: [:ingredient_cat] )
                      .where('ingredient_cats.name = "water" AND rations.id = ?', self.ration_id).first
      if has_water
        self.dice3 = rand(1..6)
      end
    end
  end

end
