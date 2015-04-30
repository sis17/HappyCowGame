class GameUsersControllerTest < ActionController::TestCase

  test "should not get index, without authentication" do
    get :index
    assert_response(401)
  end

  test "should not get specific record, without authentication" do
    get(:show, {'id' => game_users(:twosimeon).id})
    assert_response(401)
  end

  test "should not allow update, without authentication" do
    patch(:update, {'id' => game_users(:twosimeon).id, network: 0})
    assert_response(401)
  end

  test "should get index" do
    game_user = game_users(:twosimeon)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key

    get :index
    assert_response :success

    response = JSON.parse(@response.body)
    assert_equal "Simeon", response[0]['user']['name']
  end

  test "should get show for specific user only" do
    game_user = game_users(:twosimeon)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key

    get :show, {id: game_user.id}
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal "Simeon", response['user']['name']
    assert_not response['password'] # we don't want the password returned

    get :show, {id: game_users(:tworuth).id}
    assert_response(401)
  end

  test "should allow update for specific user only" do
    game_user = game_users(:twosimeon)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key

    patch(:update, {id: game_user.id, network: 0})
    assert_response :success
    response = JSON.parse(@response.body)
    assert response['success']
    assert_equal 0, response['game_user']['network']

    patch(:update, {id: game_users(:tworuth).id, network: 0})
    assert_response(401)
  end

  test "destroy a game user for specific user only" do
    game_user = game_users(:twosimeon)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key

    delete :destroy, {id: game_users(:tworuth).id}
    assert_response(401)

    delete :destroy, {id: game_user.id}
    response = JSON.parse(@response.body)
    assert response['success']

    delete :destroy, {id: game_user.id}
    assert_response(404)

    get :show, {id: game_user.id}
    assert_response(404)
  end

  test "destroy a game because all game users are destroyed" do
    game = games(:two)
    game_user = game_users(:twosimeon)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key
    delete :destroy, {id: game_user.id}
    response = JSON.parse(@response.body)
    assert response['success']

    game_user = game_users(:tworuth)
    @request.headers['UserId'] = game_user.user.id
    @request.headers['UserKey'] = game_user.user.key
    delete :destroy, {id: game_user.id}
    response = JSON.parse(@response.body)
    assert response['success']

    old_controller = @controller
    @controller = GamesController.new
    get :show, {id: game.id}
    assert_response(404)
    @controller = old_controller
  end
end
