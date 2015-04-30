require 'test_helper'

class CowTest < ActiveSupport::TestCase
  def setup
    @game = games(:two)
    @cow = cows(:twocow)
  end

  test "that a cow belongs to a game" do
    assert @cow.game
  end

  test "increasing the cow's pH marker within it's range" do
    @cow.increase_ph_marker(1)
    new_value = 6.5 + (1/5.0)
    assert_equal(new_value, @cow.ph_marker, "The cow`s ph_marker is equal to #{new_value}")
  end
  test "increasing the cow's pH marker beyond it's range" do
    @cow.increase_ph_marker(10)
    assert_equal(7.6, @cow.ph_marker, "The cow`s ph_marker is equal to 7.6")
  end
  test "decreasing the cow's pH marker within it's range" do
    @cow.decrease_ph_marker(1)
    new_value = 6.5 - (1/5.0)
    assert_equal(new_value, @cow.ph_marker, "The cow`s ph_marker is equal to #{new_value}")
  end
  test "decreasing the cow's pH marker below it's range" do
    @cow.decrease_ph_marker(20)
    assert_equal(5, @cow.ph_marker, "The cow`s ph_marker is equal to 7.6")
  end

  test "that an more energy than water in the cow's rumen decreases the rumen pH level" do
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

  test "increasing the cow's welfare marker to 1" do
    @cow.increase_welfare(1)
    assert_equal(1, @cow.welfare, "The cow`s welfare is equal to 1")
  end
  test "increasing the cow's welfare beyond it's range" do
    @cow.increase_welfare(7)
    assert_equal(5, @cow.welfare, "The cow`s welfare is equal to 5")
  end
  test "decreasing the cow's welfare to -1" do
    @cow.decrease_welfare(1)
    assert_equal(-1, @cow.welfare, "The cow`s welfare is equal to -1")
  end
  test "that decreasing the cow's welfare to -7 will kill the cow and end the game" do
    @cow.decrease_welfare(7)
    assert_equal(-7, @cow.welfare, "The cow`s welfare is equal to -7")
    assert_equal(true, @cow.check_dead, "The cow is dead")
    assert_equal(3, @cow.game.stage, "The game is in the lost stage (4)")
  end

  test "increasing the cow's body condition to 1" do
    @cow.increase_body_condition(1)
    assert_equal(1, @cow.body_condition, "The cow`s body condition is equal to 1")
  end
  test "increasing the cow's body condition beyond it's range" do
    @cow.increase_body_condition(4)
    assert_equal(3, @cow.body_condition, "The cow`s body condition is equal to 3")
  end
  test "decreasing the cow's body condition to -1" do
    @cow.decrease_body_condition(1)
    assert_equal(-1, @cow.body_condition, "The cow`s body condition is equal to -1")
  end
  test "that decreasing the cow's body condition to -3 will kill the cow and end the game" do
    @cow.decrease_body_condition(4)
    assert_equal(-4, @cow.body_condition, "The cow`s body condition is equal to -4")
    assert_equal(true, @cow.check_dead, "The cow is dead")
    assert_equal(3, @cow.game.stage, "The game is in the lost stage (4)")
  end

  test "that setting a weather event resets the cow's weather event" do
    event = events(:event_wth_hot)
    @cow.change_event(event)
    assert_equal(event.id, @cow.weather_id, "The cow weather id is #{event.id}")
    assert_equal(true, @cow.check_hot, "The cow is hot.")
    assert_equal(false, @cow.check_cold, "The cow is not cold.")
  end

  test "that setting a disease event resets the cow's disease event" do
    event = events(:event_dis_mad)
    @cow.change_event(event)
    assert_equal(event.id, @cow.disease_id, "The cow disease id is #{event.id}")
    assert_equal(true, @cow.check_mad, "The cow is mad.")
    assert_equal(false, @cow.check_constipated, "The cow is not constipated.")
  end

  test "that setting the pregnant event resets the cow's pregnancy event" do
    event = events(:event_prg)
    @cow.change_event(event)
    assert_equal(event.id, @cow.pregnancy_id, "The cow pregnancy id is #{event.id}")
  end

  test "that the cow's scores for oligos is 10 by default" do
    ing_cat = IngredientCat.where(game_id:@game.id, name: 'oligos').take
    assert_equal(10, ing_cat.meat_score, "The cow`s meat score is 10")
    assert_equal(10, ing_cat.milk_score, "The cow`s milk score is 10")
  end
  test "that when the cow's oligos marker is at 1, it's oligos score is 2" do
    @cow.increase_oligos_marker(1)
    assert_equal(1, @cow.oligos_marker, "The cow`s oligos intake is equal to 1")
    ing_cat = IngredientCat.where(game_id:@game.id, name: 'oligos').take
    assert_equal(2, ing_cat.meat_score, "The cow`s meat score is 2")
    assert_equal(2, ing_cat.milk_score, "The cow`s milk score is 2")
  end
  test "that when the cow's oligos marker is at 2, it's oligos score is 0 and welfare decreases" do
    @cow.increase_oligos_marker(1)
    @cow.increase_oligos_marker(1)
    assert_equal(2, @cow.oligos_marker, "The cow`s oligos intake is equal to 2")
    assert_equal(-1, @cow.welfare, "The cow`s welfare is equal to -1")
    ing_cat = IngredientCat.where(game_id:@game.id, name: 'oligos').take
    assert_equal(0, ing_cat.meat_score, "The cow`s meat score is 0")
    assert_equal(0, ing_cat.milk_score, "The cow`s milk score is 0")
  end
  test "that reseting the cow's oligos marker puts it's oligos score back at 10" do
    @cow.set_oligos_marker(0)
    assert_equal(0, @cow.oligos_marker, "The cow`s oligos intake is equal to 0")

    ing_cat = IngredientCat.where(game_id:@game.id, name: 'oligos').take
    assert_equal(10, ing_cat.meat_score, "The cow`s meat score is 10")
    assert_equal(10, ing_cat.milk_score, "The cow`s milk score is 10")
  end

  test "increasing the cow's muck marker to 1" do
    @cow.increase_muck_marker(1)
    assert_equal(1, @cow.muck_marker, "The cow`s muck marker is equal to 1")
  end
  test "that when increasing the cow's muck marker to 3 welfare decreases 1" do
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    assert_equal(3, @cow.muck_marker, "The cow`s muck marker is equal to 3")
    assert_equal(-1, @cow.welfare, "The cow`s welfare is equal to -1")
  end
  test "that when increasing the cow's muck marker to 5 welfare decreases 2" do
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    assert_equal(4, @cow.muck_marker, "The cow`s muck marker is equal to 4")
    @cow.increase_muck_marker(1)
    assert_equal(5, @cow.muck_marker, "The cow`s muck marker is equal to 5")
    assert_equal(-2, @cow.welfare, "The cow`s welfare is equal to -2")
  end
  test "that when increasing the cow's muck marker to 6 welfare decreases 3" do
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    assert_equal(6, @cow.muck_marker, "The cow`s muck marker is equal to 6")
    assert_equal(-3, @cow.welfare, "The cow`s welfare is equal to -3")
  end
  test "that when increasing the cow's muck marker to 7 welfare decreases 4" do
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    @cow.increase_muck_marker(1)
    assert_equal(7, @cow.muck_marker, "The cow`s muck marker is equal to 7")
    assert_equal(-4, @cow.welfare, "The cow`s welfare is equal to -4")
  end

  test "that killing the cow sets the game to a failed stage" do
    @cow.set_welfare(-7) # will kill the cow
    assert_equal 3, @cow.game.stage
  end

  test "that the method to check if the cow is constipated works" do
    event = events(:event_dis_con)
    @cow.change_event(event)
    assert @cow.check_constipated
  end

  test "that the method to check if the cow has mad cow disease works" do
    event = events(:event_dis_mad)
    @cow.change_event(event)
    assert @cow.check_mad
  end

  test "that the method to check if the cow has diarrhea works" do
    event = events(:event_dis_dir)
    @cow.change_event(event)
    assert @cow.check_diarrhea
  end

  test "that the method to check if the cow is in hot weather works" do
    event = events(:event_wth_hot)
    @cow.change_event(event)
    assert @cow.check_hot
  end

  test "that the method to check if the cow is in cold weather works" do
    event = events(:event_wth_cld)
    @cow.change_event(event)
    assert @cow.check_cold
  end
end
