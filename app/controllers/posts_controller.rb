class PostsController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :update, :destroy ]
  before_action :set_post, only: [ :show, :update, :destroy ]

  def index
    page = params[:format].to_i || 1
    @per_page = 5
    offset = (page - 1) * @per_page
    @posts = Post.limit(@per_page).offset(offset)
    render json: @posts
  end

  def show
    render json: @post
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      render json: @post, status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: @post, status: :ok
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:id])

  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post not found" }, status: :not_found
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end

  def authenticate_user!
    auth_header = request.headers["Authorization"]

    if auth_header.present?
      token = auth_header.split(" ").last
      @current_user = User.find_by(auth_token: token)
    end

    unless @current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
