require 'test_helper'

class CarddecksControllerTest < ActionController::TestCase

  test "the request should not get the index method, without authentication" do
    get :index
    assert_response(401)
  end

  test "the request should not get a specific record, without authentication" do
    get :show, id: carddecks(:basic).id
    assert_response(401)
  end

  test "the requset should get the index method" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index
    assert_response :success
    assert_equal 1, json_response.length
    assert_equal "BasicDeck", json_response[0]['name']
  end

  test "the request should get the show method for an authenticated user" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, id: carddecks(:basic).id
    assert_response :success
    assert_equal "BasicDeck", json_response['name']
  end
end
