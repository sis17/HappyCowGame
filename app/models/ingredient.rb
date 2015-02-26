class Ingredient < ActiveRecord::Base
  belongs_to :ingredient_cat, foreign_key: 'ingredient_cat_id'
  belongs_to :ration
end
