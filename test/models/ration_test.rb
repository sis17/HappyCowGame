require 'test_helper'

class RationTest < ActiveSupport::TestCase
  def setup
    @game = games(:two)
    @cow = cows(:twocow)
  end

  test "that the method describe_ingredients returns a string with labels of the ration's ingredients" do
    ration = rations(:ration2_twosimeon)
    assert_equal('<span class="label energy">energy</span> ', ration.describe_ingredients, "The description of the ration is correct.")
  end

  test "that the method has_type correctly determines if a ration has an ingredient" do
    ration1 = rations(:ration1_twosimeon)
    assert_equal(true, ration1.has_type('water'), "The first ration has water")
    ration2 = rations(:ration2_twosimeon)
    assert_equal(false, ration2.has_type('water'), "The second ration does not have water")
  end

  test "that the method count_type correctly returns the number of ingredients a ration has of that type" do
    ration1 = rations(:ration1_twosimeon)
    assert_equal(2, ration1.count_type('water'), "The first ration has 2 water")
    ration2 = rations(:ration2_twosimeon)
    assert_equal(0, ration2.count_type('water'), "The second ration has 0 water")
  end

end
