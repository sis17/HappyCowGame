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
  end
end
