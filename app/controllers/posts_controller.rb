class PostsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_is_admin, only: [:new, :create, :edit, :update]

  def index
    @posts = Post.published.paginate(page: params[:page], :per_page => 15)
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(params[:post])
    if @post.save
      flash[:notice] = "Post created."
      redirect_to posts_path
    else
      render 'new'
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update_attributes(params[:post])
      flash[:success] = "Post updated!"
      redirect_to post_path(@post)
    else
      render "edit"
    end
  end

end
