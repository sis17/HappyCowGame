require 'test_helper'

class GameTest < ActiveSupport::TestCase
  def setup
    srand(123)
  end

  test "beginning a game without any users" do
    game = Game.new(name: 'No Users', rounds_min: 5, rounds_max: 5, carddeck:carddecks(:basic))
  end
  test "beginning a game with a higher minimum number of rounds than maximum" do
    game = Game.new(name: 'Confused Rounds', rounds_min: 5, rounds_max: 2, carddeck:carddecks(:basic))
    game.save
    assert_not game.begin
  end
  test "beginning a game already in the playing phase" do
    game = games(:two)
    assert_not game.begin
  end
  test "that beginning a game moves it's stage to 1" do
    game = games(:one)
    game.begin
    assert_equal(1, game.stage, "The games's stage is now 1")
  end
  test "that beginning a game populates the game cards from the card deck" do
    game = games(:one)
    game.begin
    #game = Game.find(game.id)
    assert_equal(GameCard.where(game:game).count, Card.count+4, "There are 4 more game cards than cards")
  end
  test "beginning a game creates a cow, motile pieces and ingredient types" do
    game = games(:one)
    game.begin
    game = Game.find(game.id)
    assert_not_nil(game.cow, "The cow for the game is not nil")
    assert_equal(5, game.ingredient_cats.length, "The game has 5 ingredient categories")
    assert_equal(3, game.motiles.length, "The game has 3 motile pieces")
  end
  test "that beginning a game makes the correct number of rounds" do
    game = games(:one)
    game.begin
    last_round = game.rounds[game.rounds.length-1]
    assert_equal 1, game.round.number
    assert_equal 5, game.rounds.length
  end
  test "that in a new game, the last event is the slaughter house" do
    game = games(:one)
    game.begin
    last_round = game.rounds[game.rounds.length-1]
    assert_equal "end", last_round.event.uri
  end
  test "that in a new game every player has 2 cards" do
    game = games(:one)
    assert game.begin
    game.game_users.each do |game_user|
      assert 2, game_user.game_user_cards.length
    end
  end

  test "that the game function to get the next player works" do
    game2 = games(:two)
    game2_ruth = game_users(:tworuth)
    assert_equal(game2_ruth.id, game2.get_next_player.id, "The next user id is equal to #{game2_ruth.id}")

    game2_simeon = game_users(:twosimeon)
    game2_simeon.destroy
    assert_equal(game2_ruth.id, game2.get_next_player.id, "The next user id is equal to #{game2_ruth.id}")
  end

  test "that a ration absorbed as milk gives a score of 2" do
    game = games(:two)
    ration1 = rations(:ration1_twosimeon)
    ration1.position = positions(:pos78)
    game_user = ration1.game_user
    result = game.finish_ration(ration1)
    #assert(result[:success], "The result of finish ration on ration1 is true")
    assert_equal(2, game_user.score, "The game user's score becomes 2")
    assert_not_includes(Ration.all, ration1, "The ration is not in the database")
  end
  test "that the absorbed function only works if the ration is in a viable position" do
    game = games(:two)
    ration2 = rations(:ration2_twosimeon)
    game_user = ration2.game_user
    result = game.finish_ration(ration2)
    #assert_not(result[:success], "The result of finish ration on ration1 is fase")
    assert_equal(0, game_user.score, "The game user's score is still 0")
    assert_includes(Ration.all, ration2, "The ration is in the database")
  end
  test "that a ration absorbed as milk, when the cow is pregnant, gives a meat score of 2" do
    game = games(:two)
    ration3 = rations(:ration1_tworuth)
    game.cow.pregnancy_id = 1
    ration3.position = positions(:pos78)
    game_user = ration3.game_user
    result = game.finish_ration(ration3)
    #assert(result[:success], "The result of finish ration on ration3 is true")
    assert_equal(4, game_user.score, "The game user's score becomes 4")
  end

  test "that a ration absorbed as meat gives a score of 2" do
    game = games(:two)
    ration1 = rations(:ration1_twosimeon)
    ration1.position = positions(:pos86)
    game_user = ration1.game_user
    result = game.finish_ration(ration1)
    #assert(result[:success], "The result of finish ration on ration1 is true")
    assert_equal(2, game_user.score, "The game user's score becomes 2")
    assert_not_includes(Ration.all, ration1, "The ration is not in the database")
  end

  test "that a ration absorbed as muck gives a score of 2" do
    game = games(:two)
    ration1 = rations(:ration1_tworuth)
    ration1.position = positions(:pos95)
    game_user = ration1.game_user
    previous_action_number = Action.count
    result = game.finish_ration(ration1)
    #assert(result[:success], "The result of finish ration on ration1 is true")
    assert_equal(2, game_user.score, "The game user's score becomes 2")
    assert_not_includes(Ration.all, ration1, "The ration is not in the database")
    assert_equal(previous_action_number+1, Action.count, "1 action was created as a result of the finish ration")
  end

  test "that a ration with two oligos scores 10 for the first and 2 for the second" do
    game = games(:two)
    ration1 = rations(:ration2_tworuth)
    ration1.position = positions(:pos78)
    game_user = ration1.game_user
    result = game.finish_ration(ration1)
    cow = Cow.find(game.cow_id)
    oligos_cat = IngredientCat.where(game_id: game.id, name: 'oligos').take
    assert_equal(1, cow.oligos_marker, "The cow's oligos marker is 1")
    assert_equal(10, game_user.score, "The game user's score becomes 10")
    assert_equal(2, oligos_cat.get_score('milk'), "The next oligos scores 2")
  end

  test "that a ration absorbed when the cow is cold gets 1 less point per ingredient" do
    game = games(:two)
    ration1 = rations(:ration1_tworuth)
    ration1.position = positions(:pos78)
    game_user = ration1.game_user
    cold_event = events(:event_wth_cld)
    cold_event.makeActive(game)
    game.finish_ration(ration1)
    assert_equal(true, game.cow.check_cold, "The cow is cold")
    assert_equal(11, game_user.score, "The game user's score becomes 10")
  end

  test "that rations in the trough automatically shuffle down" do
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

  test "that a game user is created by copying in user details" do
    game = games(:one)
    user = users(:test1)
    game_user = game.create_game_user(user.id)
    assert_equal game_user.colour, user.colour
    assert_equal game_user.user.id, user.id
    assert_equal 0, game_user.score
    assert_equal "Test1", game_user.user.name
  end
  test "that a game user cannot be created once the game is begun" do
    game = games(:two)
    user = users(:test1)
    assert_not game.create_game_user(user.id)
  end
  test "that a user cannot be created twice as a game user in a game" do
    game = games(:one)
    user = users(:simeon)
    game_user = game.create_game_user(user.id)
    assert_equal game_users(:onesimeon).id, game_user.id
  end

  test "that the assign cards function gives a number game cards to the specified game user" do
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

  test "that the winner of the game gets 3 experience and everyone else gets 1 if the welfare is 2" do
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
    assert_equal(1 + (game.cow.welfare / 2), simeon.experience, "User1 has experience of 2")
    assert_equal(3 + (game.cow.welfare / 2), ruth.experience, "User2 has experience of 4")
  end

  test "that in the case of a tie, neither player gets more experience" do
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
    assert_equal(1 + (game.cow.welfare / 2), simeon.experience, "User1 has experience of 2")
    assert_equal(1 + (game.cow.welfare / 2), ruth.experience, "User2 has experience of 2")
  end

  test "that when the cow dies players lose a lot of experience" do
    cow = cows(:twocow)
    cow.decrease_welfare(7)
    game = cow.game
    simeon = game.game_users[0]
    assert_equal(-3, simeon.user.experience, "User1 has experience of -3")
  end

  test "that the card balance function distributes more ingredients at the beginning, and more actions at the end" do
    game = games(:two)
    # in it's first quater
    assert_equal(1, game.card_balance('action'), "1 action card is the balance");
    assert_equal(3, game.card_balance('ingredient'), "3 ingredient cards is the balance");
    assert_equal(0, game.card_balance('nothing'), "0 is the balance for an unknown category");
    game.round = rounds(:round4)
    assert_equal(4, game.card_balance('action'), "4 action cards is the balance");
    assert_equal(0, game.card_balance('ingredient'), "0 ingredient cards is the balance");
  end

  test "that you can't create a game user without a user" do
    game = Game.new(stage:0)
    game.save
    game_user = game.create_game_user(0)
    assert_not(game_user, "The create game user method returned false")
  end
end
