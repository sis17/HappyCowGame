require 'test_helper'

class MovesControllerTest < ActionController::TestCase

  test "the request should not get the index method, without authentication" do
    get :index
    assert_response(401)
  end

  test "the request should not get a specific record, without authentication" do
    get :show, id: moves(:move1simeon).id
    assert_response(401)
  end

  test "the requset should get the index method" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index
    assert_response :success
    assert_equal 2, json_response.length
    assert json_response[0]['round_id']
    assert json_response[0]['game_user']
  end

  test "the request should filter the index method when nested under rounds" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index, round_id: rounds(:round1).id
    assert_response :success
    assert_equal 2, json_response.length
    assert json_response[0]['round_id']
    assert json_response[0]['game_user']
  end

  test "the request should filter the index method when nested under game users" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index, game_user_id: game_users(:twosimeon).id
    assert_response :success
    assert_equal 1, json_response.length
    assert json_response[0]['ration_id']
    assert json_response[0]['round_id']
    assert json_response[0]['game_user']['user_id']
  end

  test "the reqeust should not filter the index method when nested under game users, with an unauthenticated game user" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index, game_user_id: game_users(:twosimeon).id
    assert_response(401)
  end

  test "the request should get the show method for an authenticated user" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, id: moves(:move1simeon).id
    assert_response :success
    assert json_response['game_user']['user_id']
  end

  test "the request should not get the show method when filtered by a game user, with an unauthenticated game user" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id: moves(:move1simeon).id, game_user_id: game_users(:twosimeon).id}
    assert_response(401)
  end

  test "the request should not get the show method when filtered by a round, with playing user who is not in the round" do
    user = users(:test1)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id: moves(:move1simeon).id, round_id: rounds(:round1).id}
    assert_response(401)
  end

  test "the request should not update a record for an unauthenticated user" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, id: moves(:move1simeon).id
    assert_response(401)
  end

  test "the request should not update a record for an authenticated user who does not supply an update action" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    patch :update, id: moves(:move1simeon).id
    assert_response :success
    assert_not json_response['success']
  end

  test "the request should update a record when confirming a ration for an authenticated user" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    patch :update, {id: moves(:move1ruth).id, confirm_ration: true, ration_id: rations(:ration1_tworuth).id}
    assert_response :success
    assert json_response['success']
  end

  test "the request should not update a record when confirming a ration when it is already confirmed" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    patch :update, {id: moves(:move1simeon).id, confirm_ration: true, ration_id: rations(:ration1_twosimeon).id}
    assert_response :success
    assert_not json_response['success']
  end

  test "the request should not update a record when confirming a ration when the ration does not belong to the authenticated user" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    patch :update, {id: moves(:move1simeon).id, confirm_ration: true, ration_id: rations(:ration1_tworuth).id}
    assert_response :success
    assert_not json_response['success']
  end

  test "the request should not update a record when making a move when no ration is confirmed" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    move = moves(:move1ruth)
    move.ration_id = nil
    move.save
    patch :update, {id: moves(:move1ruth).id, make_move: true, move:{selected_die:1}}
    assert_response :success
    assert_not json_response['success']
  end

  test "the request should update a record when making a move when a ration is confirmed" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    ration = rations(:ration1_tworuth)
    setup_positions(ration)
    patch :update, {id: moves(:move1ruth).id, confirm_ration: true, ration_id: ration.id}
    patch :update, {id: moves(:move1ruth).id, make_move: true, move:{selected_die:1}, position_id:positions(:pos8)}
    assert_response :success
    assert json_response['success']
    assert_equal 1, json_response['move']['selected_die']
  end

  test "the request should not update a record when making a move to change the selected die" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    setup_positions(rations(:ration1_twosimeon))
    patch :update, {id: moves(:move1simeon).id, make_move: true, move:{selected_die:2}, position_id:positions(:pos8)}
    assert_response :success
    assert json_response['success']
    assert_equal 1, json_response['move']['selected_die']
    assert_equal 1, json_response['move']['movements_left']
    assert_equal 1, json_response['move']['movements_made']
  end

  test "the request should not update a record when making a move to move to a ration to a non-neighbouring position" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    setup_positions(rations(:ration1_twosimeon))
    patch :update, {id: moves(:move1simeon).id, make_move: true, move:{selected_die:1}, position_id:positions(:pos2)}
    assert_response :success
    assert_not json_response['success']
    assert_equal 2, json_response['move']['movements_left']
    assert_equal 0, json_response['move']['movements_made']
  end

  test "the request should not update a record when making a move to move a ration too far" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    setup_positions(rations(:ration1_twosimeon))
    patch :update, {id: moves(:move1simeon).id, make_move: true, move:{selected_die:1}, position_id:positions(:pos8)}
    patch :update, {id: moves(:move1simeon).id, make_move: true, move:{selected_die:1}, position_id:positions(:pos9)}
    patch :update, {id: moves(:move1simeon).id, make_move: true, move:{selected_die:1}, position_id:positions(:pos9)}
    assert_response :success
    assert_not json_response['success']
    assert_equal 0, json_response['move']['movements_left']
    assert_equal 2, json_response['move']['movements_made']
  end
end
