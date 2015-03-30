class MoveTest < ActiveSupport::TestCase
  def setup
    game_user = game_users(:twosimeon)
    round = rounds(:round1)
    @move = Move.new(game_user: game_user, round: round)
  end

  test "set dice" do
    @move.ration_id = rations(:ration1_twosimeon)
    @move.save
    cow = cows(:twocow)
    cow.ph_marker = 5.2
    cow.save
    @move = Move.find(@move.id)
    @move.set_dice
    # used puts to test randomness
  end

  test "move ration" do
    @move.ration = rations(:ration1_twosimeon) # confirm ration
    @move.set_dice
    @move.save
    @move = Move.find(@move.id)
    @move.select_dice(1)
    movements = @move.movements_left
    assert_equal(@move.get_movements, @move.movements_left, "The move has the number of movements left that were on the dice")
    @move.confirm_move(positions(:pos7))
    assert_equal(movements-1, @move.movements_left, "The move has one less movement's left.")
    assert_equal(1, @move.movements_made, "The move has one movement made.")
  end
end
