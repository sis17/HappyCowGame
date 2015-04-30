require 'test_helper'

class GameUserTest < ActiveSupport::TestCase
  def setup
    srand(123)
    @game_user = game_users(:twosimeon)
  end

  test "that a game user belongs to a game" do
    assert @game_user.game
  end
  test "that a game user belongs to a user" do
    assert @game_user.user
  end

  test "that a ration will not be created without ingredients" do
    response = @game_user.make_ration([])
    assert_not response[:success]
  end

  test "that a ration will not be created with ingredients that do not belong to the new owner" do
    false_guc = GameUserCard.new(game_card:game_cards(:gc1), game_user:game_users(:tworuth))
    false_guc.save
    response = @game_user.make_ration([{id:game_user_cards(:guc1).id},{id:false_guc.id}])
    assert_not response[:success]
  end

  test "that a ration will be created with correct ingredients" do
    response = @game_user.make_ration([{id:game_user_cards(:guc1).id},{id:game_user_cards(:guc2).id}])
    assert response[:success]
    assert_equal 2, response[:ration]['ingredients'].length
  end

  test "that a user's cards used to create a ration are destroyed" do
    response = @game_user.make_ration([{id:game_user_cards(:guc1).id},{id:game_user_cards(:guc2).id}])
    assert response[:success]
    assert_equal 2, @game_user.game_user_cards.length
  end
end
