require 'test_helper'

class RationsControllerTest < ActionController::TestCase

  test "the request should not get the index method, without authentication" do
    get :index
    assert_response(401)
  end

  test "the request should not get a specific record, without authentication" do
    get(:show, {id: rations(:ration1_twosimeon).id})
    assert_response(401)
  end

  test "the requset should get the index method" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index
    assert_response :success
    assert_equal 6, json_response.length
    assert_equal 2, json_response[0]['ingredients'].length
    assert json_response[0]['position']['order']
  end

  test "the request should get the index method when filtered by the game user" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index, game_user_id: game_users(:twosimeon).id
    assert_response :success
    assert_equal 2, json_response.length
  end

  test "the request should get show method for an authenticated user" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id: rations(:ration1_twosimeon).id}
    assert_response :success
    assert_equal 1, json_response['position']['order']
  end

  test "the request should create a ration for an authenticated user" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    energy_card_id = game_user_cards(:guc1)
    protien_card_id = game_user_cards(:guc2)
    post :create, {ration:{game_user_id:game_users(:twosimeon).id,
        ingredients:[{id:energy_card_id}, {id:protien_card_id}]}}
    assert_response :success
    assert json_response['success']
    assert_equal 2, json_response['ration']['ingredients'].length
  end

  test "the request should not create more than one ration a turn" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    card_id1 = game_user_cards(:guc1)
    card_id2 = game_user_cards(:guc2)
    post :create, {ration:{game_user_id:game_users(:twosimeon).id,
        ingredients:[{id:card_id1}]}}
    assert_response :success

    post :create, {ration:{game_user_id:game_users(:twosimeon).id,
        ingredients:[{id:card_id2}]}}
    assert_response :success
    assert_not json_response['success']
    assert_not json_response['ration']
  end

  test "the request should not create a ration using an un-owned ingredient" do
    user = users(:ruth)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    card_id1 = game_user_cards(:guc1) # belongs to simeon

    post :create, {ration:{game_user_id:game_users(:tworuth).id,
        ingredients:[{id:card_id1}]}}
    assert_response :success
    assert_not json_response['success']
    assert_not json_response['ration']
  end

  test "the request should not create a ration with non-ingredient cards" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    card_id1 = game_user_cards(:guc3)
    card_id2 = game_user_cards(:guc4)
    post :create, {ration:{game_user_id:game_users(:twosimeon).id,
        ingredients:[{id:card_id1}, {id:card_id2}]}}
    assert_response :success
    assert_not json_response['success']
    assert_not json_response['ration']
  end

  test "the request should not create a ration for an unauthorised user" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    energy_card_id = game_user_cards(:guc1)
    protien_card_id = game_user_cards(:guc2)
    post :create, {ration:{game_user_id:game_users(:tworuth).id,
        ingredients:[{id:energy_card_id}, {id:protien_card_id}]}}
    assert_response(401)
  end
end
