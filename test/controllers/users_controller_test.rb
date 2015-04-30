class UsersControllerTest < ActionController::TestCase

  test "should not get index, without authentication" do
    get :index
    assert_response(401)
  end

  test "should not get specific record, without authentication" do
    get(:show, {'id' => users(:simeon).id})
    assert_response(401)
  end

  test "should not allow update, without authentication" do
    patch(:update, {'id' => users(:simeon).id, profile: {name:'John'}})
    assert_response(401)
  end

  test "should get index" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key
    #puts @request.env
    get :index #, {}, {'UserId' => user.id, 'UserKey' => user.key})
    assert_response :success

    users = JSON.parse(@response.body)
    assert_equal "rmc3@aber.ac.uk", users[0]['email']
  end

  test "should get show for specific user only" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    get :show, {id: user.id}
    assert_response :success
    user = JSON.parse(@response.body)
    assert_equal "sis17@aber.ac.uk", user['email']

    get :show, {id: users(:ruth).id}
    assert_response(401)
  end

  test "should allow update for specific user only" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch(:update, {id: users(:simeon).id, profile: {name:'John'}})
    assert_response :success
    response = JSON.parse(@response.body)
    assert response['success']

    patch(:update, {id: users(:simeon).id, user: {name:'John'}})
    assert_response :success
    response = JSON.parse(@response.body)
    assert_not response['success']

    patch(:update, {id: users(:ruth).id, profile: {name:'John'}})
    assert_response(401)
  end

  test "update of users name, email, colour and password" do
    user = users(:simeon)
    @request.headers['UserId'] = user.id
    @request.headers['UserKey'] = user.key

    patch(:update, {id: users(:simeon).id, profile: {name:'John', email: 'sis@aber.ac.uk', colour: 'none', password: 'glitch'}})
    assert_response :success
    response = JSON.parse(@response.body)
    assert response['success']

    get :show, {id: user.id}
    user = JSON.parse(@response.body)
    assert_equal "John", user['name']
    assert_equal "sis@aber.ac.uk", user['email']
    assert_equal "none", user['colour']
  end

  test "login of user" do
    user = users(:simeon)

    post :login, {email: 'nothing', password: 'nothing'}
    response = JSON.parse(@response.body)
    assert_not response['success']

    post :login, {email: 'sis17@aber.ac.uk', password: 'nothing'}
    response = JSON.parse(@response.body)
    assert_not response['success']

    post :login, {email: 'sis17@aber.ac.uk', password: 'test'}
    response = JSON.parse(@response.body)
    assert response['success']
    assert_equal 'Simeon', response['user']['name']
    assert response['key']
  end

  test "create a user" do
    user = users(:simeon)

    post :create, {user: {email: 'sis17@aber.ac.uk', password: 'test', name: 'Simeon'}}
    response = JSON.parse(@response.body)
    assert_not response['success']

    post :create, {user: {email: 'test1@aber.ac.uk', name: 'Test'}}
    response = JSON.parse(@response.body)
    assert_not response['success']

    post :create, {user: {email: 'test1@aber.ac.uk', password: 'test', name: 'Test'}}
    response = JSON.parse(@response.body)
    assert_not response['success']

    post :create, {user: {email: 'test2@aber.ac.uk', password: 'test', name: 'Test2'}}
    response = JSON.parse(@response.body)
    assert response['success']
    assert response['key']
    assert_equal 'Test2', response['user']['name']
    assert_equal 'test2@aber.ac.uk', response['user']['email']
  end
end
