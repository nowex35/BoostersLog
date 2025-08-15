require "test_helper"

class Api::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_users_url
    assert_response :success
  end

  test "should get show" do
    user = users(:one)
    get api_v1_user_url(user)
    assert_response :success
  end

  test "should get create" do
    post api_v1_users_url, params: { user: { uid: "new-uid", name: "Taro", email: "taro@example.com" } }
    assert_response :created
  end
end
