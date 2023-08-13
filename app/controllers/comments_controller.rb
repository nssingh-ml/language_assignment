class CommentsController < ApplicationController
  # skip_before_action :authenticate_request
  before_action :authenticate_request, only: [:create, :delete]
  # before_action :authenticate_user!, only: [:create, :destroy]
    # before_action :set_comment, only: [:show, :update, :destroy]

  def index
    comments = Comment.all
    render json: comments
  end

  def show
    post = Post.find(params[:post_id])
        comments = Comment.joins(:user).where(post: post)
        comments_data = comments.map do |comment|
            {
                id: comment.id,
                post_id: comment.post_id,
                author_id: comment.user_id,
                author_name: comment.user.name,
                comment_date: comment.created_at,
                content: comment.content
            }
        end
      render json: comments_data, status: :ok
    # render json: @comment, include: :user
  end

  def create

    comment = Comment.new(comment_params)
    comment.user_id=@current_user.id
    if comment.save
      render json: comment, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @comment=Comment.find(params[:id])
    comment = current_user.comments.build(post: @post, text: params[:text])
    if comment.save
      @post.increment_commenets_count
      render json: comment, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end

    # if @comment.update(comment_params)
    #   render json: @comment
    # else
    #   render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    # end
  end

  def delete
    @comment=Comment.find(params[:comment_id])
    @comment.destroy
    render json: { message: 'Comment deleted successfully' }


    #this is used when access with post resources
    # comment = @post.comments.find_by(id: params[:id])
    # if comment
    #   comment.destroy
    #   @post.decrement_comments_count
    #   render json: { message: 'Comment removed successfully' }
    # else
    #   render json: { error: 'Comment not found' }, status: :not_found
    # end

  end

  private

  # def set_comment
  #   @comment = Comment.find(params[:id])
  # end

  def comment_params
    # params.require(:comment).permit(:content, :user_id, :post_id)
    params.permit(:content, :post_id)
  end
end
