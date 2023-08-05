class LikesController < ApplicationController
  skip_before_action :authenticate_request
  # before_action :authenticate_user!, only: [:create, :destroy]
    before_action :set_like, only: [:show, :destroy]

  def index
    likes = Like.all
    render json: likes
  end

  def show
    render json: @like, include: :user
  end

  def create

    if @current_user.already_liked?(@post)
        @current_user.likes.find_by(post: @post).destroy
        @post.decrement_likes_count
        render json: { errors: "You have already liked this post" }, status: :unprocessable_entity
    else
    like = @current_user.likes.build(post: @post)
    if like.save
        # puts "counted"
        @post.increment_likes_count
        render json: like, status: :created
    else
        render json: { errors: like.errors.full_messages }, status: :unprocessable_entity
    end
    end

    # like = Like.new(like_params)
    # if like.save
    #   render json: like, status: :created
    # else
    #   render json: { errors: like.errors.full_messages }, status: :unprocessable_entity
    # end
  end

  def destroy
    @like.destroy
    render json: { message: 'Like removed successfully' }
  end

  private

  def set_like
    @like = Like.find(params[:id])
  end

  def like_params
    params.require(:like).permit(:user_id, :post_id)
  end
end
