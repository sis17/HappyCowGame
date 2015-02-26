class IngredientCat < ActiveRecord::Base
  has_many :ingredients
  belongs_to :game
end
