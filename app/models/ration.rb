class Ration < ActiveRecord::Base
  belongs_to :game_user

  belongs_to :user
  belongs_to :game_user
  belongs_to :position

  has_many :ingredients
  has_many :moves

  def describe_ingredients
    description = ''
    self.ingredients.each do |ingredient|
      description += '<span class="label '+ingredient.ingredient_cat.name+'">'+ingredient.ingredient_cat.name+'</span> '
    end
    return description
  end

  def has_type(type)
    self.ingredients.each do |ing|
      return true if ing.ingredient_cat.name == type
    end
    return false
  end
  def count_type(type)
    count = 0
    self.ingredients.each do |ing|
      count += 1 if ing.ingredient_cat.name == type
    end
    return count
  end

  def as_json(options={})
    super(
      :include => [
        {game_user: {:include => :user}},
        {ingredients: {:include => :ingredient_cat}},
        :position,
        :moves
      ]
    )
  end
end
