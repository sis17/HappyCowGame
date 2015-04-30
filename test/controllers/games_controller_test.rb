require 'test_helper'

class GamesControllerTest < ActionController::TestCase

  test "the request should not get the index method, without authentication" do
    get :index
    assert_response(401)
  end

  test "the request should not get a specific record, without authentication" do
    get(:show, {'id' => games(:two).id})
    assert_response(401)
  end

  test "the request should not update a record, without authentication" do
    patch(:update, {'id' => games(:two).id, done_turn: 'true'})
    assert_response(401)
  end

  test "the request should delete a record, without authentication" do
    delete :destroy, {id: games(:two).id}
    assert_response(401)
  end

  test "the requset should get the index method" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index
    assert_response :success
    assert_equal 3, json_response.length
  end

  test "the request should get the show method" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id:games(:two).id}
    assert_response :success
    assert_equal 1, json_response['stage']
    assert_equal 'PlayingGame', json_response['name']
  end

  test "the request should not get the show method for a user who is not part of the game" do
    user = users(:test1)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id:games(:two).id}
    assert_response(401)
  end

  test "the request should allow finishing a turn for the current player" do
    # allow simeon to update the turn
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:two).id, done_turn: true}
    assert_response :success
  end

  test "the request should not allow finishing a turn for a player other than the current player" do
    # should fail simeon to update the turn a second time, it's no longer his turn
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:two).id, done_turn: true}
    assert_response(401)
  end

  test "the request should not allow finishing a turn for user who is not a player" do
    user = users(:test1)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:two).id, done_turn: true}
    assert_response(401)
  end

  test "the request should not allow an update of game details once the game is in stage two" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:two).id, name: 'Happy Cow Game', rounds_min: 2}
    assert_response :success
    assert_not json_response['success']
  end

  test "the request should allow an updtae of game details for a game in stage one" do
    # should fail simeon to update the game, it's been started
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:one).id, name: 'Happy Cow Game', rounds_min: 2}
    assert_response :success
    assert json_response['success']
    assert_equal 'Happy Cow Game', json_response['game']['name']
    assert_equal 2, json_response['game']['rounds_min']
  end

  test "the request should not allow an update of game details for a non creator" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:one).id, name: 'Happy Cow Game'}
    assert_response(401)
  end

  test "the request should not allow a non-creator to begin a game" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:one).id, begin: true}
    assert_response(401)
  end

  test "the request should allow the game creator to begin a game" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:one).id, begin: true}
    assert_response :success
    assert json_response['success']
    assert_equal 1, json_response['game']['stage']
    assert json_response['game']['round']
  end

end
