require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "the request should not get the index method, without authentication" do
    get :index
    assert_response(401)
  end

  test "the request should not get a specific record, without authentication" do
    get(:show, {'id' => users(:simeon).id})
    assert_response(401)
  end

  test "the request should not update, without user authentication" do
    patch(:update, {'id' => users(:simeon).id, profile: {name:'John'}})
    assert_response(401)
  end

  test "the requset should get the index method" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :index
    assert_response :success
    assert_equal "rmc3@aber.ac.uk", json_response[0]['email']
  end

  test "the request should get the show method for a specific user only" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id: user.id}
    assert_response :success
    assert_equal "sis17@aber.ac.uk", user['email']

    get :show, {id: users(:ruth).id}
    assert_response(401)
  end

  test "the request should update a record for a specific user only" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch(:update, {id: users(:simeon).id, profile: {name:'John'}})
    assert_response :success
    assert json_response['success']

    patch(:update, {id: users(:simeon).id, user: {name:'John'}})
    assert_response :success
    assert_not json_response['success']

    patch(:update, {id: users(:ruth).id, profile: {name:'John'}})
    assert_response(401)
  end

  test "the request should update a record with a user's users name, email, colour and password" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch(:update, {id: users(:simeon).id, profile: {name:'John', email: 'sis@aber.ac.uk', colour: 'none', password: 'glitch'}})
    assert_response :success
    assert json_response['success']

    get :show, {id: user.id}
    assert_equal "John", json_response['name']
    assert_equal "sis@aber.ac.uk", json_response['email']
    assert_equal "none", json_response['colour']
  end

  test "the request should not return a user and token with an incorrect username" do
    user = users(:simeon)
    post :login, {email: 'nothing', password: 'nothing'}
    assert_not json_response['success']
  end
  test "the request should not return a user and token with an incorrect password" do
    user = users(:simeon)
    post :login, {email: 'sis17@aber.ac.uk', password: 'nothing'}
    assert_not json_response['success']
  end
  test "the request should return a user and token with with a correct username and password" do
    user = users(:simeon)
    post :login, {email: 'sis17@aber.ac.uk', password: 'test'}
    assert json_response['success']
    assert_equal 'Simeon', json_response['user']['name']
    assert json_response['key']
  end

  test "the request should not create a user with an existing username" do
    post :create, {user: {email: 'sis17@aber.ac.uk', password: 'test', name: 'Simeon'}}
    assert_not json_response['success']
  end
  test "the request should not create a user without a password" do
    post :create, {user: {email: 'test1@aber.ac.uk', name: 'Test'}}
    assert_not json_response['success']
  end
  test "the request should create a user given a username, name and password" do
    post :create, {user: {email: 'test2@aber.ac.uk', password: 'test', name: 'Test2'}}
    assert json_response['success']
    assert json_response['key']
    assert_equal 'Test2', json_response['user']['name']
    assert_equal 'test2@aber.ac.uk', json_response['user']['email']
  end
end
