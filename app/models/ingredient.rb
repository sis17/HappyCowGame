class Ingredient < ActiveRecord::Base
  belongs_to :ingredient_cat
  belongs_to :ration
end
