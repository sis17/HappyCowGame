require 'test_helper'

class IngredientTest < ActiveSupport::TestCase

  test "an ingredient has a ration" do
    ingredient = ingredients(:water1)
    assert_not_nil(ingredient.ration, "The ingredient has a ration")
  end

  test "an ingredient has an ingredient category" do
    ingredient = ingredients(:water1)
    assert_not_nil(ingredient.ingredient_cat, "The ingredient has an ingredient category")
  end
end
