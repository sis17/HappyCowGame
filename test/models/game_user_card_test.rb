require 'test_helper'

class GameUserCardTest < ActiveSupport::TestCase
  test "use medical insurance" do
    game_user = game_users(:twosimeon)
    assert_equal(game_user.game_user_cards.length, 4, "The game user has 4 cards")
    medical_card = game_user_cards(:guc4)
    response = medical_card.use
    assert_not(response[:success], "The medical insturance card was not used, not enough other cards.")
    GameUserCard.new(game_user: game_user, game_card: game_cards(:gc2)).save
    assert_equal(5, GameUser.find(game_user.id).game_user_cards.length, "The game user has 5 cards.")
    medical_card = GameUserCard.find(medical_card.id)
    response = medical_card.use
    assert(response[:success], "The medical insturance card was not used, not enough other cards.")
    assert_equal(4, GameUser.find(game_user.id).game_user_cards.length, "The game user has 4 cards left.")
  end

end
