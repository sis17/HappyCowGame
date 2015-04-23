require 'test_helper'

class CowTest < ActiveSupport::TestCase
  def setup
    @game = games(:two)
    @cow = cows(:twocow)
  end

  test "increase the ph_marker" do
    @cow.increase_ph_marker(1)
    new_value = 6.5 + (1/5.0)
    assert_equal(new_value, @cow.ph_marker, "The cow`s ph_marker is equal to #{new_value}")

    @cow.increase_ph_marker(10)
    assert_equal(7.6, @cow.ph_marker, "The cow`s ph_marker is equal to 7.6")
  end
  test "decrease the ph_marker" do
    @cow.decrease_ph_marker(1)
    new_value = 6.5 - (1/5.0)
    assert_equal(new_value, @cow.ph_marker, "The cow`s ph_marker is equal to #{new_value}")

    @cow.decrease_ph_marker(20)
    assert_equal(5, @cow.ph_marker, "The cow`s ph_marker is equal to 7.6")
  end

  test "the turn effect of water and energy" do
    pos = positions(:pos60)
    ration1 = rations(:ration1_twosimeon)
    ration1.position = pos
    ration1.save
    ration2 = rations(:ration2_twosimeon)
    ration2.position = pos
    ration2.save
    ration3 = rations(:ration1_tworuth)
    ration3.position = pos
    ration3.save

    @cow.set_ph_marker(6.5) # reset it
    @cow.turn_effects
    # there are 2 water and 3 energy
    assert_equal(6.3, @cow.ph_marker, 'The cow ph_marker is equal to 6.3')
  end

  test "increase the welfare" do
    @cow.increase_welfare(1)
    assert_equal(1, @cow.welfare, "The cow`s welfare is equal to 1")

    @cow.increase_welfare(6)
    assert_equal(5, @cow.welfare, "The cow`s welfare is equal to 3")
  end
  test "decrease the welfare" do
    @cow.decrease_welfare(1)
    assert_equal(-1, @cow.welfare, "The cow`s welfare is equal to -1")

    @cow.decrease_welfare(6)
    game = Game.find(@game.id)
    assert_equal(-7, @cow.welfare, "The cow`s welfare is equal to -5")
    assert_equal(true, @cow.check_dead, "The cow is dead")
    assert_equal(4, game.stage, "The game is in the lost stage (4)")
  end

  test "increase the body condition" do
    @cow.increase_body_condition(1)
    assert_equal(1, @cow.body_condition, "The cow`s body condition is equal to 1")

    @cow.increase_body_condition(4)
    assert_equal(3, @cow.body_condition, "The cow`s body condition is equal to 3")
  end
  test "decrease the body condition" do
    @cow.decrease_body_condition(1)
    assert_equal(-1, @cow.body_condition, "The cow`s body condition is equal to -1")

    @cow.decrease_body_condition(3)
    game = Game.find(@game.id)
    assert_equal(-4, @cow.body_condition, "The cow`s body condition is equal to -4")
    assert_equal(true, @cow.check_dead, "The cow is dead")
    assert_equal(4, game.stage, "The game is in the lost stage (4)")
  end

  test "change weather event" do
    event = events(:event_wth_hot)
    @cow.change_event(event)
    assert_equal(event.id, @cow.weather_id, "The cow weather id is #{event.id}")
    assert_equal(true, @cow.check_hot, "The cow is hot.")
    assert_equal(false, @cow.check_cold, "The cow is not cold.")
  end

  test "change disease event" do
    event = events(:event_dis_mad)
    @cow.change_event(event)
    assert_equal(event.id, @cow.disease_id, "The cow disease id is #{event.id}")
    assert_equal(true, @cow.check_mad, "The cow is mad.")
    assert_equal(false, @cow.check_constipated, "The cow is not constipated.")
  end

  test "change pregnancy event" do
    event = events(:event_prg)
    @cow.change_event(event)
    assert_equal(event.id, @cow.pregnancy_id, "The cow pregnancy id is #{event.id}")
  end

  test "increase the oligos" do
    ing_cat = IngredientCat.where(game_id:@game.id, name: 'oligos').take
    assert_equal(10, ing_cat.meat_score, "The cow`s meat score is 10")
    assert_equal(10, ing_cat.milk_score, "The cow`s milk score is 10")

    @cow.increase_oligos_marker(1)
    assert_equal(1, @cow.oligos_marker, "The cow`s oligos intake is equal to 1")
    ing_cat = IngredientCat.where(game_id:@game.id, name: 'oligos').take
    assert_equal(2, ing_cat.meat_score, "The cow`s meat score is 2")
    assert_equal(2, ing_cat.milk_score, "The cow`s milk score is 2")

    @cow.increase_oligos_marker(1)
    assert_equal(2, @cow.oligos_marker, "The cow`s oligos intake is equal to 2")
    assert_equal(-1, @cow.welfare, "The cow`s welfare is equal to -1")
    ing_cat = IngredientCat.where(game_id:@game.id, name: 'oligos').take
    assert_equal(0, ing_cat.meat_score, "The cow`s meat score is 0")
    assert_equal(0, ing_cat.milk_score, "The cow`s milk score is 0")
  end
  test "reset the oligos" do
    @cow.set_oligos_marker(0)
    assert_equal(0, @cow.oligos_marker, "The cow`s oligos intake is equal to 0")

    ing_cat = IngredientCat.where(game_id:@game.id, name: 'oligos').take
    assert_equal(10, ing_cat.meat_score, "The cow`s meat score is 10")
    assert_equal(10, ing_cat.milk_score, "The cow`s milk score is 10")
  end

  test "increase the muck marker" do
    @cow.increase_muck_marker(1)
    assert_equal(1, @cow.muck_marker, "The cow`s muck marker is equal to 1")

    @cow.increase_muck_marker(2)
    assert_equal(3, @cow.muck_marker, "The cow`s muck marker is equal to 3")
    assert_equal(-1, @cow.welfare, "The cow`s welfare is equal to -1")

    @cow.increase_muck_marker(1)
    assert_equal(4, @cow.muck_marker, "The cow`s muck marker is equal to 4")

    @cow.increase_muck_marker(1)
    assert_equal(5, @cow.muck_marker, "The cow`s muck marker is equal to 5")
    assert_equal(-2, @cow.welfare, "The cow`s welfare is equal to -2")

    @cow.increase_muck_marker(1)
    assert_equal(6, @cow.muck_marker, "The cow`s muck marker is equal to 6")
    assert_equal(-3, @cow.welfare, "The cow`s welfare is equal to -3")

    @cow.increase_muck_marker(1)
    assert_equal(7, @cow.muck_marker, "The cow`s muck marker is equal to 7")
    assert_equal(-4, @cow.welfare, "The cow`s welfare is equal to -4")
  end
end
