class ListsController < ApplicationController

    before_action :authenticate_request

  def create
    list = current_user.lists.build(list_params)
    if list.save
      render json: list, status: :created
    else
      render json: { errors: list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    lists = current_user.lists
    render json: lists
  end

  def show
    list = current_user.lists.find(params[:id])
    render json: list, include: :posts
  end

  def share
    list = current_user.lists.find(params[:id])
    # Implement share logic here
    render json: { message: "List shared successfully." }
  end

  def add_post
    list = current_user.lists.find(params[:id])
    post = Post.find(params[:post_id])

    if list.posts << post
      render json: { message: "Post added to list successfully." }
    else
      render json: { error: "Failed to add post to list." }, status: :unprocessable_entity
    end
  end


  def list_posts
    list = List.find(params[:list_id])
    list_posts = list.posts.includes(:user).all
    
    post_data = list_posts.map do |post|
        {
          post_id: post.id,
          title: post.title,
          topic: post.topic.name,
          text: post.description,
          # image: post.image,
          likes_count: post.likes_count,
          comments_count: post.commenets_count,
          author_name: post.user.name
        }
    end
    render json: post_data, status: :ok
  end

  private

  def list_params
    params.permit(:name)
  end

end
