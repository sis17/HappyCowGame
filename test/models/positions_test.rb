class PositionTest < ActiveSupport::TestCase
  def setup

  end

  test "is not free with motile" do
    # position 50 has a motile piece
    game = games(:two)
    ration1 = rations(:smallfiber)
    position = positions(:pos50)
    result = position.is_free(game, ration1)
    assert_not(result, "Position 50 is not free, it has a motile element")
  end

  test "is free" do
    game = games(:two)
    ration1 = rations(:smallfiber)
    position = positions(:pos12)
    result = position.is_free(game, ration1)
    assert(result, "Position 12 is free.")
  end

  test "is not free with more fiber ration" do
    game = games(:two)
    ration1 = rations(:smallfiber)
    position = positions(:pos12)

    ration2 = rations(:lotsoffiber)
    ration2.position = position
    ration2.save
    #position = positions(:pos12)
    result = position.is_free(game, ration1)
    assert_not(result, "Position 12 is not free, it has a ration with more fiber")
  end

  test "is free with less fiber ration" do
    game = games(:two)
    ration1 = rations(:lotsoffiber)
    position = positions(:pos12)

    ration2 = rations(:smallfiber)
    ration2.position = position
    ration2.save
    #position = positions(:pos12)
    result = position.is_free(game, ration1)
    assert(result, "Position 12 is free, it has a ration with less fiber")
  end
end
