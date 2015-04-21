class MoveTest < ActiveSupport::TestCase
  def setup
    srand(123)
    #puts rand(99)
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
    pos_next = positions(:pos7)
    @move.ration.position.positions.push(pos_next)
    @move.confirm_move(pos_next.id, false)

    assert_equal(movements-1, @move.movements_left, "The move has one less movement's left.")
    assert_equal(1, @move.movements_made, "The move has one movement made.")
  end

  test "consume ration" do
    @move.ration = rations(:ration1_twosimeon) # confirm ration
    @move.set_dice
    @move.save
    @move = Move.find(@move.id)
    @move.dice1 = 1
    @move.select_dice(1)
    game_user = game_users(:twosimeon)
    pos_next = positions(:pos_milk)
    @move.ration.position.positions.push(pos_next)
    messages = @move.confirm_move(pos_next.id, false)

    assert_equal(0, @move.movements_left, "The move has no movement's left.")
    assert_equal(1, @move.movements_made, "The move has one movement made.")
    assert(@move.ration.destroyed?, "The ration has been removed.")
    assert_equal(game_user.score+2, GameUser.find(game_user.id).score, "The game user has 2 more points.")
  end
end
