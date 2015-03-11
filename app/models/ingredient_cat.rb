class IngredientCat < ActiveRecord::Base
  has_many :ingredients
  belongs_to :game

  def get_score(type)
    # work out the score
    if type == 'milk'
      score = self.milk_score
    end
    if type == 'meat'
      score = self.meat_score
    end
    if type == 'muck'
      score = self.muck_score
    end

    # reduce oligos score
    if self.name == 'oligos'
      self.game.cow.increase_oligos(type)
      if type == 'milk'
        self.milk_score = if self.milk_score > 2 then self.milk_score = 2 else self.milk_score = 0 end
      end
      if type == 'meat'
        self.meat_score = if self.meat_score > 2 then self.meat_score = 2 else self.meat_score = 0 end
      end
      self.save
    end

    return score
  end
end
