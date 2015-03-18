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
      description += '<span class="label '+ingredient.ingredient_cat.name+'">ingredient.ingredient_cat.name</span> '
    end
    return description
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
