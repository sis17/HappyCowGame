require 'test_helper'

class PositionsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get nested index" do
    get :index, game_id: games(:two).id
    assert_response :success
  end

  test "should get show" do
    get :show, {id: positions(:pos1).id}
    assert_response :success
  end

  test "should get graph" do
    ration1 = rations(:ration1_twosimeon)
    pos = positions(:pos1)
    pos2 = positions(:pos7)
    pos.positions.push(pos2)
    ration1.position = pos2
    ration1.save
    pos.save
    get :graph, id: pos.id, game_id: games(:two).id, depth: 1
    assert_response :success
    assert_equal 2, json_response.length
    assert_equal 1, json_response[pos.id.to_s]['order']
    assert_equal 1, json_response[pos.id.to_s]['links'].length
  end

end
