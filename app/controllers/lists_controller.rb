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
    begin
      list = current_user.lists.find(params[:id])
      recipient_email=params[:recipient_email]
      #share logic here
      if list
          ShareListAndPostMailer.share_list_email(list, @current_user, recipient_email).deliver_now
          # redirect_to list, notice: "List shared successfully"
          render json: {message: "list shared successfully"}, status: :ok
      else
          render json: {message: 'list not found'}, status: :not_found
      end
    rescue => e
      render  json: { error: e.message }, status: :internal_server_error 
    end
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
