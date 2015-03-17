class Move < ActiveRecord::Base
  belongs_to :game_user
  belongs_to :round
  belongs_to :ration

  def set_dice
    # check if the ration is in the intestine (for constipation)
    if self.round.game.cow.check_constipated
      self.dice1 = rand(1..6)
      if self.ration.position.area_id != 4
        self.dice2 = rand(1..6)
        self.add_water
      end
    else
      self.dice1 = rand(1..6)
      self.dice2 = rand(1..6)
      self.add_water
    end
    self.save
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
