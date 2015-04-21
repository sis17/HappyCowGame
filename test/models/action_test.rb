require 'test_helper'

class ActionTest < ActiveSupport::TestCase
  def setup
    @game = games(:two)
  end

  test "get actions for a game" do
    @game.round.actions
    assert_equal(1, @game.round.actions.length, "The game has one action.")
    action = @game.round.actions[0]
    game_user = game_users(:twosimeon)
    assert_equal(action.game_user.id, game_user.id, "The action belongs to #{game_user.user.name}.")
  end

  test "playing a card creates an action" do
    game_user_card = game_user_cards(:guc3)
    result = game_user_card.use
    game = Game.find(@game.id)
    assert_equal(2, game.round.actions.length, "There are two actions in the current round.")
  end

  test "creating a ration creates an action" do
    game_card = game_cards(:gc1)
    game_user = game_users(:twosimeon)

    energy_card = GameUserCard.new(game_user: game_user, game_card: game_card)

    game_user.make_ration([{id:energy_card.id}])
    game = Game.find(@game.id)
    assert_equal(2, game.round.actions.length, "There are two actions in the current round.")
  end
end
