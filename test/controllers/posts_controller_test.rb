require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:one)
    @auth_headers = { Authorization: "Bearer #{@user.auth_token}" }
  end

  test "should get index" do
    get posts_url(1), headers: @auth_headers, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
    assert_not_empty json_response
    assert_equal @post.title, json_response.first["title"]
  end

  test "pagination test" do
    get posts_url(1), headers: @auth_headers, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal json_response.count, 5

    get posts_url(2), headers: @auth_headers, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal json_response.count, 1
  end

  test "should show post" do
    get post_url(@post), as: :json
    assert_response :success

    # Check the response body for correct post data
    json_response = JSON.parse(response.body)
    assert_equal @post.id, json_response["id"]
    assert_equal @post.title, json_response["title"]
    assert_equal @post.content, json_response["content"]
    assert_equal @user.id, json_response["user_id"]
  end

  test "should create post" do
    assert_difference("Post.count", 1) do
      post posts_url, params: { post: { title: "New Post", content: "Some content" } }, headers: @auth_headers, as: :json
    end

    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "New Post", json_response["title"]
    assert_equal "Some content", json_response["content"]
    assert_equal @user.id, json_response["user_id"]
  end

  test "should not create post without title" do
    assert_no_difference("Post.count") do
      post posts_url, params: { post: { content: "Content without a title" } }, headers: @auth_headers, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["title"], "can't be blank"
  end

  test "should update post" do
    patch post_url(@post), params: { post: { title: "Updated Title", content: "Updated Content" } }, headers: @auth_headers, as: :json
    assert_response :success

    @post.reload
    assert_equal "Updated Title", @post.title
    assert_equal "Updated Content", @post.content
  end

  test "should not update post with invalid data" do
    patch post_url(@post), params: { post:  { title: "", content: "Updated content" }   }, headers: @auth_headers, as: :json
    assert_response :unprocessable_entity

    @post.reload
    assert_not_equal "", @post.title
  end

  test "should delete post" do
    assert_difference("Post.count", 1) do
      post posts_url, params: { post: { title: "created Post", content: "Some content to delete" } }, headers: @auth_headers, as: :json
    end
    assert_response :created
    json_response = JSON.parse(response.body)
    created_post_id = json_response["id"]

    assert_difference("Post.count", -1) do
      delete post_url(created_post_id), headers: @auth_headers, as: :json
    end
    assert_response :no_content
  end

  test "should not allow unauthorized access" do
    post posts_url, params: { post: { title: "New Post", content: "Some content" } }, as: :json
    assert_response :unauthorized

    assert_no_difference("Post.count") do
      post posts_url, params: { post: { title: "New Post", content: "Some content" } }, as: :json
    end
  end
end
