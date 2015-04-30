require 'test_helper'

class CardsControllerTest < ActionController::TestCase

  test "the request should not get the index method, without authentication" do
    get :index
    assert_response(401)
  end

  test "the request should not get a specific record, without authentication" do
    get(:show, {id: cards(:card_energy).id})
    assert_response(401)
  end

  test "the requset should get the index method" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index
    assert_response :success
    assert_equal 19, json_response.length
    assert json_response[0]['title']
  end

  test "the request should get game cards filtered by games" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index, game_id: games(:two).id
    assert_response :success
    assert_equal 19, json_response.length
    assert json_response[0]['card']['title']
  end

  test "the request should get game user cards filtered by game users" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index, game_user_id: game_users(:twosimeon).id
    assert_response :success
    assert_equal 4, json_response.length
    assert json_response[0]['game_card']['card']['title']
  end

  test "the request should not get game user cards filtered by game users, with an unauthenticated game user" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index, game_user_id: game_users(:twosimeon).id
    assert_response(401)
  end

  test "the request should get a card for an authenticated user" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id: cards(:card_energy).id}
    assert_response :success
    assert_equal "Energy", json_response['title']
  end

  test "the request should get a game card filtered by a game" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id: game_cards(:gc1).id, game_id: games(:two).id}
    assert_response :success
    assert_equal "Energy", json_response['card']['title']
  end

  test "the request should get a game user card filtered by a game user" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id: game_user_cards(:guc1).id, game_user_id: game_users(:twosimeon).id}
    assert_response :success
    assert_equal "Energy", json_response['game_card']['card']['title']
  end

  test "the request should not get a game user card filtered by a game user, with an unauthenticated game user" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id: game_user_cards(:guc1).id, game_user_id: game_users(:twosimeon).id}
    assert_response(401)
  end

  test "the request should not get a game card filtered by a game, with a non playing user" do
    user = users(:test1)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id: game_cards(:gc1).id, game_id: games(:two).id}
    assert_response(401)
  end

  test "the request should update a record of a card" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id: cards(:card_energy).id}
    assert_response :success
    assert_not json_response['success']
  end

  test "the request should update a record of a game card" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id: game_cards(:gc1).id, game_id: games(:two).id}
    assert_response :success
    assert_not json_response['success']
  end

  test "the request should not update a record of a game user card for an unauthenticated user" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch :update, {id: game_user_cards(:guc1).id, game_user_id: game_users(:twosimeon).id}
    assert_response(401)
  end

  test "the request should update a record of a game user card for an authenticated user" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    patch :update, {id: game_user_cards(:guc3).id, game_user_id: game_users(:twosimeon).id, use: true}
    assert_response :success
    assert json_response['success']
    assert_equal "Card Used", json_response['message']['title']
  end

  test "the request should not use an ingredient card" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    patch :update, {id: game_user_cards(:guc1).id, game_user_id: game_users(:twosimeon).id, use: true}
    assert_response :success
    assert_not json_response['success']
  end

  test "the request should not update a game user card without a use parameter" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    patch :update, {id: game_user_cards(:guc4).id, game_user_id: game_users(:twosimeon).id} # no use parameter
    assert_response :success
    assert_not json_response['success']
  end

  test "the request should not delete a card" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    delete :destroy, {id: cards(:card_energy).id}
    assert_response :success
    assert_not json_response['success']
  end

  test "the request should not delete a game card" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    delete :destroy, {id: game_cards(:gc1).id, game_id: games(:two).id}
    assert_response :success
    assert_not json_response['success']
  end

  test "the request should delete a game user card for an authenticated user" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    delete :destroy, {id: game_user_cards(:guc1).id, game_user_id: game_users(:twosimeon).id}
    assert_response :success
    assert json_response['success']
    assert_equal "Card Discarded", json_response['message']['title']

    delete :destroy, {id: game_user_cards(:guc1).id, game_user_id: game_users(:twosimeon).id}
    assert_response(404)
  end
end
