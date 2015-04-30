require 'test_helper'

class RoundsControllerTest < ActionController::TestCase

  test "the request should not get the index method, without authentication" do
    get :index
    assert_response(401)
  end

  test "the request should not get a specific record, without authentication" do
    get(:show, {'id' => rounds(:round1).id})
    assert_response(401)
  end

  test "the requset should get the index method" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index
    assert_response :success
    assert json_response[0]['current_phase']
    assert_equal 5, json_response.length
  end

  test "the request should get the show method" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, id: rounds(:round1).id
    assert_response :success
    assert_equal 1, json_response['number']
  end

end
