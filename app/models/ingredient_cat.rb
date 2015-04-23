class IngredientCat < ActiveRecord::Base
  has_many :ingredients
  belongs_to :game

  def get_score(type)
    # work out the score depending on the type
    return self.milk_score if type == 'milk'
    return self.meat_score if type == 'meat'
    return self.muck_score if type == 'muck'
    return nil
  end
end
