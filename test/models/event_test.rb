require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @game = games(:two)
    @cow = cows(:twocow)
  end

  test "making the constipation event the active disease event" do
    event = events(:event_dis_con)
    event.makeActive(@game)
    assert_equal(-1, @game.cow.welfare, "The cow's welfare is -1")
    assert_equal(true, @game.cow.check_constipated, "The is constipated")
  end

  test "making the diarrhea event the active disease event" do
    event = events(:event_dis_dir)
    event.makeActive(@game)
    assert_equal(-1, @game.cow.welfare, "The cow's welfare is -1")
    assert_equal(true, @game.cow.check_diarrhea, "The cow has diarrhea")
  end

  test "making the cold weather event the active weather event" do
    event = events(:event_wth_cld)
    event.makeActive(@game)
    assert_equal(true, @game.cow.check_cold, "The cow is cold")
    ration = rations(:ration2_twosimeon)
    ration.position = positions(:pos78) # set the ration to the milk position
    @game.finish_ration(ration)
    simeon = game_users(:twosimeon)
    simeon = GameUser.find(simeon.id)
    assert_equal(5, simeon.score, "Simeon has a score of 0, the absorbed ration made 0 points")
  end

  test "making the hot weather event the active weather event" do
    event = events(:event_wth_hot)
    event.makeActive(@game)
    assert_equal(true, @game.cow.check_hot, "The cow is hot")
  end

  test "making the good weather event the active weather event" do
    event = events(:event_wth_gdw)
    event.makeActive(@game)
    assert_equal(false, @game.cow.check_hot, "The cow is not hot")
    assert_equal(false, @game.cow.check_cold, "The cow is not cold")
    assert_equal(1, @game.cow.welfare, "The cow's welfare is 1")
  end

  test "making the mad cow crisis event the active disease event" do
    event = events(:event_dis_mad)
    event.makeActive(@game)
    @game.ingredient_cats.each do |ing_cat|
      assert_equal(1, ing_cat.meat_score, "The energy meat score is 1") if ing_cat.name == 'energy'
      assert_equal(0, ing_cat.meat_score, "The water meat score is 0") if ing_cat.name == 'water'
      assert_equal(3, ing_cat.meat_score, "The protein meat score is 3") if ing_cat.name == 'protein'
    end
    assert_equal(true, @game.cow.check_mad, "The cow is mad")
  end

  test "making the mad cow crisis event inactive again" do
    event = events(:event_dis_mad)
    event.makeActive(@game)
    event.makeInactive(@game)
    @game.ingredient_cats.each do |ing_cat|
      assert_equal(2, ing_cat.meat_score, "The energy meat score is 2") if ing_cat.name == 'energy'
      assert_equal(1, ing_cat.meat_score, "The water meat score is 1") if ing_cat.name == 'water'
      assert_equal(4, ing_cat.meat_score, "The protein meat score is 4") if ing_cat.name == 'protein'
    end
  end
end
