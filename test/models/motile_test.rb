require 'test_helper'

class MotileTest < ActiveSupport::TestCase
  def setup
    srand(123)
    @motile = motiles(:motile1)
  end

  test "a motile has a game" do
    assert_not_nil(@motile.game, "The motile has a game")
  end

  test "a motile has a position" do
    assert_not_nil(@motile.position, "The motile has a position")
  end

  test "move to an empty place" do
    # fixtures won't add positions, so do it manually
    @motile.position.positions.push(positions(:pos56))
    @motile.position.positions.push(positions(:pos50))
    @motile.move
    assert_equal(positions(:pos56).order, @motile.position.order, "The motile has moved to position 56")
  end

  test "does not move to position 61" do
    # fixtures won't add positions, so do it manually
    @motile.position = positions(:pos60)
    @motile.position.positions.push(positions(:pos60))
    @motile.move
    @motile.move
    @motile.move
    @motile.move
    @motile.move
    assert_not_equal(positions(:pos61).order, @motile.position.order, "The motile has not moved to position 61")
  end

  test "move onto a ration" do
    ration = rations(:ration1_twosimeon)
    ration.position = positions(:pos50)
    ration.save
    ration_ingredients = ration.ingredients.length
    # fixtures won't add positions, so do it manually
    @motile.position.positions.push(positions(:pos50))
    @motile.move
    ration = Ration.find(ration.id)
    assert_equal(positions(:pos50).order, @motile.position.order, "The motile has moved to position 50")
    assert_equal(ration_ingredients-1, ration.ingredients.length, "The ration has 1 less ingredient")
  end
end
