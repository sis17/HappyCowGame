require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "begin a game" do
    game = games(:one)
    game.begin

    game = Game.find(game.id)
    assert_equal(1, game.stage, "The games's stage is now 1")
    assert_equal(GameCard.where(game:game).count, Card.count+4, "There are 4 more game cards than cards")
    assert_not_nil(game.cow, "The cow for the game is not nil")
    assert_equal(1, game.round.number, "The initial round's number is 1")
    assert_equal(5, game.rounds.length, "The game has 5 rounds")
    assert_equal(5, game.ingredient_cats.length, "The game has 5 ingredient categories")
    assert_equal(3, game.motiles.length, "The game has 3 motile pieces")
  end

  test "get next player" do
    game2 = games(:two)
    game2_ruth = game_users(:tworuth)
    assert_equal(game2_ruth.id, game2.get_next_player.id, "The next user id is equal to #{game2_ruth.id}")

    game2_simeon = game_users(:twosimeon)
    game2_simeon.destroy
    assert_equal(game2_ruth.id, game2.get_next_player.id, "The next user id is equal to #{game2_ruth.id}")
  end

  test "finish ration milk" do
    game = games(:two)
    ration1 = rations(:ration1_twosimeon)
    ration1.position = positions(:pos_milk)
    game_user = ration1.game_user
    result = game.finish_ration(ration1)
    #assert(result[:success], "The result of finish ration on ration1 is true")
    assert_equal(2, game_user.score, "The game user's score becomes 2")
    assert_not_includes(Ration.all, ration1, "The ration is not in the database")

    ration2 = rations(:ration2_twosimeon)
    result = game.finish_ration(ration2)
    #assert_not(result[:success], "The result of finish ration on ration1 is fase")
    assert_equal(2, game_user.score, "The game user's score is still 2")

    ration3 = rations(:ration1_tworuth)
    game.cow.pregnancy_id = 1
    ration3.position = positions(:pos_milk)
    game_user = ration3.game_user
    result = game.finish_ration(ration3)
    #assert(result[:success], "The result of finish ration on ration3 is true")
    assert_equal(4, game_user.score, "The game user's score becomes 4")
  end

  test "finish ration meat" do
    game = games(:two)
    ration1 = rations(:ration1_twosimeon)
    ration1.position = positions(:pos_meat)
    game_user = ration1.game_user
    result = game.finish_ration(ration1)
    #assert(result[:success], "The result of finish ration on ration1 is true")
    assert_equal(2, game_user.score, "The game user's score becomes 2")
    assert_not_includes(Ration.all, ration1, "The ration is not in the database")
  end

  test "finish ration muck" do
    game = games(:two)
    ration1 = rations(:ration1_tworuth)
    ration1.position = positions(:pos_muck)
    game_user = ration1.game_user
    previous_action_number = Action.count
    result = game.finish_ration(ration1)
    #assert(result[:success], "The result of finish ration on ration1 is true")
    assert_equal(2, game_user.score, "The game user's score becomes 2")
    assert_not_includes(Ration.all, ration1, "The ration is not in the database")
    assert_equal(previous_action_number+1, Action.count, "1 action was created as a result of the finish ration")
  end

  test "finish ration with oligos" do
    game = games(:two)
    ration1 = rations(:ration2_tworuth)
    ration1.position = positions(:pos_milk)
    game_user = ration1.game_user
    result = game.finish_ration(ration1)
    cow = Cow.find(game.cow_id)
    oligos_cat = IngredientCat.where(game_id: game.id, name: 'oligos').take
    assert_equal(1, cow.oligos_marker, "The cow's oligos marker is 1")
    assert_equal(10, game_user.score, "The game user's score becomes 10")
    assert_equal(2, oligos_cat.get_score('milk'), "The next oligos scores 2")
  end

  test "finish ration when cold" do
    game = games(:two)
    ration1 = rations(:ration1_tworuth)
    ration1.position = positions(:pos_milk)
    game_user = ration1.game_user
    cold_event = events(:event_wth_cld)
    cold_event.makeActive(game)
    game.finish_ration(ration1)
    assert_equal(true, game.cow.check_cold, "The cow is cold")
    assert_equal(11, game_user.score, "The game user's score becomes 10")
  end

  test "arrange trough from position 1" do
    game = games(:two)
    ration1 = rations(:ration1_twosimeon)
    ration1.position = positions(:pos7)

    game.arrange_trough(positions(:pos1))
    ration2 = Ration.find(rations(:ration2_twosimeon).id)
    ration3 = Ration.find(rations(:ration1_tworuth).id)
    ration4 = Ration.find(rations(:ration2_tworuth).id)

    assert_equal(1, ration2.position.order, "ration2 is now at position 1")
    assert_equal(2, ration3.position.order, "ration3 is now at position 2")
    assert_equal(3, ration4.position.order, "ration4 is now at position 3")
    pos4 = positions(:pos4)
    assert_equal(0, pos4.rations.length, "position 4 has no rations")
  end

  test "sort trough based on energy" do
    game = games(:two)
    game.sort_trough('energy')
    ration1 = Ration.find(rations(:ration1_twosimeon).id)
    ration2 = Ration.find(rations(:ration2_twosimeon).id)
    ration3 = Ration.find(rations(:ration1_tworuth).id)
    ration4 = Ration.find(rations(:ration2_tworuth).id)

    assert_equal(1, ration3.position.order, "ration3 is now at position 1")
    assert_equal(2, ration2.position.order, "ration2 is now at position 2")
    assert_equal(3, ration1.position.order, "ration1 is now at position 3")
    assert_equal(4, ration4.position.order, "ration4 is now at position 4")
  end

  test "sort trough based on water" do
    game = games(:two)
    game.sort_trough('water')
    ration1 = Ration.find(rations(:ration1_twosimeon).id)
    ration2 = Ration.find(rations(:ration2_twosimeon).id)
    ration3 = Ration.find(rations(:ration1_tworuth).id)
    ration4 = Ration.find(rations(:ration2_tworuth).id)

    assert_equal(1, ration1.position.order, "ration1 is now at position 1")
    assert_equal(2, ration2.position.order, "ration2 is now at position 2")
    assert_equal(3, ration3.position.order, "ration3 is now at position 3")
    assert_equal(4, ration4.position.order, "ration4 is now at position 4")
  end

  test "assign cards" do
    game = games(:two)
    simeon = game_users(:twosimeon)
    simeon_card_count = simeon.game_user_cards.length
    game.assign_cards(simeon, 2)
    simeon = GameUser.find(simeon.id)
    assert_equal(simeon_card_count+2, simeon.game_user_cards.length, "Game user 1 has 2 more cards")

    ruth = game_users(:tworuth)
    ruth_card_count = ruth.game_user_cards.length
    game.assign_cards(ruth, 0)
    ruth = GameUser.find(ruth.id)
    assert_equal(ruth_card_count, ruth.game_user_cards.length, "Game user 2 has the same number of cards")
    game.assign_cards(ruth, 60)
    ruth = GameUser.find(ruth.id)
    assert_equal(ruth_card_count+60, ruth.game_user_cards.length, "Game user 2 has 60 more cards")
  end

  test "finish with a winner" do
    game = games(:two)
    simeon = game_users(:twosimeon)
    simeon.score = 1
    simeon.save
    ruth = game_users(:tworuth)
    ruth.score = 5
    ruth.save
    game.finish
    simeon = User.find(simeon.user_id)
    ruth = User.find(ruth.user_id)
    assert_equal(2, simeon.experience, "User1 has experience of 2")
    assert_equal(4, ruth.experience, "User2 has experience of 4")
  end

  test "finish with a tie" do
    game = games(:two)
    simeon = game_users(:twosimeon)
    simeon.score = 3
    simeon.save
    ruth = game_users(:tworuth)
    ruth.score = 3
    ruth.save
    game.finish
    simeon = User.find(simeon.user_id)
    ruth = User.find(ruth.user_id)
    assert_equal(2, simeon.experience, "User1 has experience of 2")
    assert_equal(2, ruth.experience, "User2 has experience of 2")
  end

  test "finish with dead cow" do
    cow = cows(:twocow)
    cow.kill
    game = Game.find(cow.game.id)
    game.finish
    simeon = game.game_users[0]
    assert_equal(1, simeon.user.experience, "User1 has experience of 1")
  end

  test "card balance" do
    game = games(:two)
    # in it's first quater
    assert_equal(1, game.card_balance('action'), "1 action card is the balance");
    assert_equal(3, game.card_balance('ingredient'), "3 ingredient cards is the balance");
    assert_equal(0, game.card_balance('nothing'), "0 is the balance for an unknown category");
    game.round = rounds(:round4)
    assert_equal(4, game.card_balance('action'), "4 action cards is the balance");
    assert_equal(0, game.card_balance('ingredient'), "0 ingredient cards is the balance");
  end

  test "add game user" do
    game = Game.new
    user = users(:simeon)
    game_user = game.create_game_user(user.id)
    assert_equal(game_user.user.id, user.id, "The new game user has the same user id as the user.")
    assert_equal(game_user.colour, user.colour, "The new game user has the same colour as the user.")

    game_user = game.create_game_user(0)
    assert_not(game_user, "The create game user method returned false")

    user = users(:ruth)
    game_user = game.create_game_user(user.id)
    assert_equal('Ruth', game_user.user.name, "The new game user has the name Ruth.")
  end
end
