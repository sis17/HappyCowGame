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

  test "should not get index" do
    @request.env["UserId"] = users(:simeon).id
    @request.env["UserKey"] = users(:simeon).key
    get :index
    assert_response :success
  end
end
