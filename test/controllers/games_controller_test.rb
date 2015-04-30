require 'test_helper'

class GamesControllerTest < ActionController::TestCase

  test "should not get index, without authentication" do
    get :index
    assert_response(401)
  end

  test "should not get specific record, without authentication" do
    get(:show, {'id' => games(:two).id})
    assert_response(401)
  end

  test "should not allow update, without authentication" do
    patch(:update, {'id' => games(:two).id, done_turn: 'true'})
    assert_response(401)
  end

  test "should not allow destroy, without authentication" do
    delete :destroy, {id: games(:two).id}
    assert_response(401)
  end

  test "should get index" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index
    assert_response :success

    response = JSON.parse(@response.body)
    assert_equal 1, response[0]['stage']
    assert_equal 'PlayingGame', response[0]['name']
  end

  test "should get show" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id:games(:two).id}
    assert_response :success

    response = JSON.parse(@response.body)
    assert_equal 1, response['stage']
    assert_equal 'PlayingGame', response['name']

    user = users(:test1)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id:games(:two).id}
    assert_response(401)
  end

  test "should allow done turn for current player" do
    # allow simeon to update the turn
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:two).id, done_turn: true}
    assert_response :success
  end

  test "should not allow done turn for non current player" do
    # should fail simeon to update the turn a second time, it's no longer his turn
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:two).id, done_turn: true}
    assert_response(401)
  end

  test "should not allow done turn update for non player" do
    user = users(:test1)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:two).id, done_turn: true}
    assert_response(401)
  end

  test "should not allow details update for started game" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:two).id, done_turn: true}
    assert_response :success
    response = JSON.parse(@response.body)
    assert_not response['success']
  end

  test "should allow details update for unstarted game" do
    # should fail simeon to update the game, it's been started
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:one).id, name: 'Happy Cow Game', rounds_min: 2}
    assert_response :success
    response = JSON.parse(@response.body)
    assert response['success']
    assert_equal 'Happy Cow Game', response['game']['name']
    assert_equal 2, response['game']['rounds_min']
  end

  test "should not allow details update for a non creator" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:one).id, name: 'Happy Cow Game'}
    assert_response(401)
  end

  test "should not allow begin for non creator" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id:games(:one).id, begin: true}
    assert_response(401)
  end

  test "should allow begin for creator" do

  end

end
