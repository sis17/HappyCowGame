require 'test_helper'

class GameUserCardTest < ActiveSupport::TestCase
  def setup
    srand(123)
    @game_user = game_users(:twosimeon)
  end

  test "that you cannot use a card with no specified action" do
    game = games(:two)
    card = Card.new(title:"Do Nothing", description:"Does nothing", image:"", category:"action", rating:0, points:0, uri:"nill")
    game_card = GameCard.new(game: game, card: card)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)

    result = game_user_card.use
    assert_equal(false, result[:success], "The result of using the card was false.")
  end

  test "that you cannot use a card that is not an action card" do
    game = games(:two)
    game_user = game_users(:twosimeon)
    card = Card.new(title:"Dirt", description:"Does nothing.", image:"", category:"dirt", rating:0, points:0, uri:"nill")
    game_card = GameCard.new(game: game, card: card)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)

    result = game_user_card.use
    assert_equal(false, result[:success], "The result of using the card was false.")
  end

  test "the action of the card acidodis plus" do
    game_card = game_cards(:gc6)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(7.1, cows(:twocow).ph_marker, "The cow's pH has increased to 7.1.")
  end

  test "the action of the card acidodis minus" do
    game_card = game_cards(:gc7)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(5.9, cows(:twocow).ph_marker, "The cow's pH has decreased to 5.9.")
  end

  test "the action of the card rumination" do
    # test with no available ration
    game_card = game_cards(:gc8)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use
    assert_equal(false, result[:success], "The result of using the card was false.")

    # make a ration available
    ration = rations(:ration1_twosimeon)
    ration.position = positions(:pos12)
    ration.save

    game_card = game_cards(:gc8)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use
    ration = Ration.find(ration.id)
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(7, ration.position.order, "The ration was placed on position 7.")
    assert_equal(1, cows(:twocow).welfare, "The cow's welfare increased to 1.")
  end

  test "the action of the card thief" do
    game_card = game_cards(:gc9)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use

    rations = Ration.all
    first_ration = rations[0]
    last_ration = rations[rations.length-1]

    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(2, last_ration.ingredients.length, "The last ration has 2 ingredients.")
    assert_equal(1, first_ration.ingredients.length, "The first ration has 1 ingredient.")
  end

  test "the action of the card vet" do
    #create a disease
    cow = cows(:twocow)
    cow.disease_id = events(:event_dis_con).id
    cow.welfare = -3

    game_card = game_cards(:gc10)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use

    cow = Cow.find(cow.id)
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(nil, cow.disease_id, "The cow has no disease.")
    assert_equal(0, cow.welfare, "The cow's welfare has been moved to 0.")
  end

  test "the action of the card clean stables" do
    cow = cows(:twocow)
    cow.muck_marker = 2
    cow.save

    game_card = game_cards(:gc11)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use

    cow = Cow.find(cow.id)
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(2, @game_user.score, "The player's score is 2.")
    assert_equal(0, cow.muck_marker, "The cow's muck marker has been moved to 0.")
  end

  test "the action of the card animal welfare activists" do
    other_game_card = game_cards(:gc1)
    other_game_user = game_users(:tworuth)
    GameUserCard.new(game_card: other_game_card, game_user: other_game_user)
    GameUserCard.new(game_card: other_game_card, game_user: other_game_user)
    GameUserCard.new(game_card: other_game_card, game_user: other_game_user)

    game_card = game_cards(:gc12)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use

    cow = Cow.find(cows(:twocow).id)
    other_game_user = GameUser.find(other_game_user.id)
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(0, other_game_user.game_user_cards.length, "The player has 1 card.")
    assert_equal(3, cow.welfare, "The cow's welfare has been moved to 3.")
  end

  test "the action of the card deficiency" do
    # test first without any oligos increased
    cow = @game_user.game.cow
    cow.welfare = 0
    cow.save
    game_card = game_cards(:gc13)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use
    cow = Cow.find(cow.id)
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(0, cow.oligos_marker, "The cow's oligos marker has been moved to 0.")
    #assert_equal(-1, cow.welfare, "The cow's welfare has been moved to -1.")

    # then increase the oligos and test again
    cow = @game_user.game.cow
    cow.oligos_marker = 2
    cow.welfare = 0
    cow.save

    game_card = game_cards(:gc13)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(0, cow.oligos_marker, "The cow's oligos marker has been moved to 0.")
    #assert_equal(0, cow.welfare, "The cow's welfare stayed the same.")
  end

  test "the action of the card medical insurance" do
    #test with 4 cards, and decreased welfare
    game_card = game_cards(:gc14)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    game_user_card.save
    other_game_card = game_cards(:gc1)
    GameUserCard.new(game_card: other_game_card, game_user: @game_user).save
    GameUserCard.new(game_card: other_game_card, game_user: @game_user).save
    GameUserCard.new(game_card: other_game_card, game_user: @game_user).save
    GameUserCard.new(game_card: other_game_card, game_user: @game_user).save
    #puts 'card length: '+@game_user.game_user_cards.length.to_s
    cow = cows(:twocow)
    cow.welfare = -4
    cow.disease_id = events(:event_dis_con).id
    cow.save

    result = game_user_card.use
    cow = Cow.find(cow.id)
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(0, cow.welfare, "The cow's welfare moved to 0.")
    assert_equal(nil, cow.disease_id, "The cow has no disease.")
    #assert_equal(4, @game_user.game_user_cards.length, "The game user has 4 cards left.")

    # test without enough cards
    @game_user.game_user_cards.destroy_all
    game_card = game_cards(:gc14)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use
    cow = Cow.find(cow.id)
    assert_equal(false, result[:success], "The result of using the card was false.")
  end

  test "the action of the card saponins (fiber in rumen turned to protien)" do
    ration = Ration.new(game_user:@game_user, position:positions(:pos25))
    ration.save
    Ingredient.new(ration:ration, ingredient_cat:ingredient_cats(:two_fibercategory)).save
    Ingredient.new(ration:ration, ingredient_cat:ingredient_cats(:two_fibercategory)).save

    game_card = game_cards(:gc15)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use

    protiens_size = Ingredient.where(ration: ration, ingredient_cat:ingredient_cats(:two_protiencategory)).size
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(1, protiens_size, "The ration now has 2 protien.")
  end

  test "the action of the card probiotics" do
    cow = cows(:twocow)
    cow.ph_marker = 7
    cow.welfare = 0
    cow.save

    game_card = game_cards(:gc16)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use
    cow = Cow.find(cow.id)
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(6.5, cow.ph_marker, "The cow's pH marker was set to 6.5.")
    assert_equal(1, cow.welfare, "The cow's welfare marker increased to 1.")
  end

  test "the action of the card farm improvements" do
    cow = cows(:twocow)
    cow.weather_id = events(:event_wth_cld)
    cow.save

    game_card = game_cards(:gc17)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use
    cow = Cow.find(cow.id)
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(nil, cow.weather_id, "The cow's weather event has been removed.")
  end

  test "the action of the card bioreactor" do
    game_card = game_cards(:gc18)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use
    assert_equal(true, result[:success], "The result of using the card was true.")

    category = IngredientCat.where(game:@game_user.game, name:'water').take
    assert_equal(2, category.muck_score, "The muck score for water is 2.")
    category = IngredientCat.where(game:@game_user.game, name:'protien').take
    assert_equal(2, category.muck_score, "The muck score for protien is 2.")
    category = IngredientCat.where(game:@game_user.game, name:'energy').take
    assert_equal(2, category.muck_score, "The muck score for energy is 2.")
  end

  test "the action of the card high sugar grass" do
    # put fiber in the intestines
    ration = Ration.new(game_user:@game_user, position:positions(:pos78))
    ration.save
    Ingredient.new(ration:ration, ingredient_cat:ingredient_cats(:two_fibercategory)).save
    Ingredient.new(ration:ration, ingredient_cat:ingredient_cats(:two_fibercategory)).save

    game_card = game_cards(:gc18)
    game_user_card = GameUserCard.new(game_card: game_card, game_user: @game_user)
    result = game_user_card.use
    game_user = game_users(:twosimeon)
    assert_equal(true, result[:success], "The result of using the card was true.")
    assert_equal(2, game_user.score, "The game users's score increased to 2.")
  end

end
