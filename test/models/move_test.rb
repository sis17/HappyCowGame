class MoveTest < ActiveSupport::TestCase
  def setup
    srand(123)
    game_user = game_users(:twosimeon)
    round = rounds(:round1)
    @move = Move.new(game_user: game_user, round: round)
  end

  test "setting the dice for a move" do
    @move.ration = rations(:ration2_twosimeon) #  no water
    @move.save
    @move = Move.find(@move.id)
    @move.set_dice
    assert_equal 6, @move.dice1
    assert_equal 3, @move.dice2
    assert_not @move.dice3
  end

  test "setting the dice for a move with water" do
    @move.ration = rations(:ration1_twosimeon) # at least one water
    @move.save
    @move = Move.find(@move.id)
    @move.set_dice
    assert_equal 6, @move.dice1
    assert_equal 3, @move.dice2
    assert_equal 5, @move.dice3
  end

  test "setting the dice for a move with a low rumen pH" do
    @move.ration = rations(:ration1_twosimeon)
    @move.save
    cow = cows(:twocow)
    cow.ph_marker = 5.2
    cow.save
    @move = Move.find(@move.id)
    @move.set_dice
    assert_equal 5, @move.dice1 # -1 for low ph
    assert_equal 0, @move.dice2
    assert_equal 0, @move.dice3
  end

  test "setting the dice for a move with a high rumen pH" do
    @move.ration = rations(:ration1_twosimeon)
    @move.save
    cow = cows(:twocow)
    cow.ph_marker = 7.4
    cow.save
    @move = Move.find(@move.id)
    @move.set_dice
    assert_equal 6, @move.dice1
    assert_equal 0, @move.dice2
    assert_equal 0, @move.dice3
  end

  test "setting the dice for a move with the cow constipated" do
    ration = rations(:ration1_twosimeon)
    ration.position = positions(:pos68)
    ration.save
    @move.ration = ration
    @move.save
    cow = cows(:twocow)
    cow.change_event(events(:event_dis_con))
    @move = Move.find(@move.id)
    @move.set_dice
    assert_equal 3, @move.dice1
    assert_not @move.dice2
    assert_not @move.dice3
  end

  test "setting the dice for a move with the cow having diarrhea" do
    ration = rations(:ration1_twosimeon)
    ration.position = positions(:pos68)
    ration.save
    @move.ration = ration
    @move.save
    cow = cows(:twocow)
    cow.change_event(events(:event_dis_dir))
    @move = Move.find(@move.id)
    @move.set_dice
    assert_equal 5, @move.dice1
    assert_not @move.dice2
    assert_not @move.dice3
  end

  test "that with a selected dice, a ration can move between positions" do
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

  test "that a ration is consumed when ending it's turn on the milk position" do
    @move.ration = rations(:ration1_twosimeon) # confirm ration
    @move.set_dice
    @move.save
    @move = Move.find(@move.id)
    @move.dice1 = 1
    @move.select_dice(1)
    game_user = game_users(:twosimeon)
    pos_next = positions(:pos78)
    @move.ration.position.positions.push(pos_next)
    messages = @move.confirm_move(pos_next.id, false)

    assert_equal(0, @move.movements_left, "The move has no movement's left.")
    assert_equal(1, @move.movements_made, "The move has one movement made.")
    assert(@move.ration.destroyed?, "The ration has been removed.")
    assert_equal(game_user.score+2, GameUser.find(game_user.id).score, "The game user has 2 more points.")
  end
end
