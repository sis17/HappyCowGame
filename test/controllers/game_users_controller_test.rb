require 'test_helper'

class GameUsersControllerTest < ActionController::TestCase

  test "the request should not get the index method, without authentication" do
    get :index
    assert_response(401)
  end

  test "the request should not get a specific record, without authentication" do
    get(:show, {id: game_users(:twosimeon).id})
    assert_response(401)
  end

  test "the request should not update a record, without authentication" do
    patch(:update, {id: game_users(:twosimeon).id, network: 0})
    assert_response(401)
  end

  test "the request should get the index method" do
    game_user = game_users(:twosimeon)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key

    get :index
    assert_response :success
    assert_equal "Simeon", json_response[0]['user']['name']
  end

  test "the request should get the show method for specific user only" do
    game_user = game_users(:twosimeon)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key

    get :show, {id: game_user.id}
    assert_response :success
    assert_equal "Simeon", json_response['user']['name']
    assert_not json_response['password'] # we don't want the password returned

    get :show, {id: game_users(:tworuth).id}
    assert_response(401)
  end

  test "the request should update a record for an authorised user" do
    game_user = game_users(:twosimeon)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key

    patch(:update, {id: game_user.id, network: 0})
    assert_response :success
    assert json_response['success']
    assert_equal 0, json_response['game_user']['network']
  end

  test "the request should delete a record for a specific user only" do
    game_user = game_users(:twosimeon)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key

    delete :destroy, {id: game_users(:tworuth).id}
    assert_response(401)

    delete :destroy, {id: game_user.id}
    assert json_response['success']

    delete :destroy, {id: game_user.id}
    assert_response(404)

    get :show, {id: game_user.id}
    assert_response(404)
  end

  test "the request to delete a game user should destroy a game because they are the only game user" do
    game = games(:two)
    game_user = game_users(:twosimeon)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key
    delete :destroy, {id: game_user.id}
    assert json_response['success']

    game_user = game_users(:tworuth)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key
    delete :destroy, {id: game_user.id}
    assert json_response['success']

    old_controller = @controller
    @controller = GamesController.new
    get :show, {id: game.id}
    assert_response(404)
    @controller = old_controller
  end
end
