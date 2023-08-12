class PostsController < ApplicationController
    # skip_before_action :authenticate_request
    before_action :authenticate_request, only: [:new, :create, :update, :destroy]
    # before_action :set_post, only: [:show, :update, :destroy, :more_posts_by_author]

  def index
    posts = Post.all

    # Filter by author name
    if params[:user_id]
        user = User.find(params[:user_id])
        posts = user.posts
        # posts = posts.joins(:user_id).where("authors.name LIKE ?", "%#{params[:user_id]}%")
      end
  
    # Filter by published date
    if params[:date]
    date = Date.parse(params[:date])
    posts = posts.where("published_at >= ? AND published_at < ?", date, date + 1.day)
    end

    # Check if the user has provided a sorting parameter desc of numbers
  if params[:sort_by] == 'likes'
    posts = posts.left_joins(:likes)
                .select('posts.*, COUNT(DISTINCT likes.id) AS likes_count')
                .group('posts.id')
                .order('likes_count DESC')
  elsif params[:sort_by] == 'comments'
    posts = posts.left_joins(:comments)
                .select('posts.*, COUNT(DISTINCT comments.id) AS comments_count')
                .group('posts.id')
                .order('comments_count DESC')
  end
    render json: posts
    
  end

  def show
    # @post = Post.find(params[:id])
    if @current_user && !@current_user.already_following?(@post.user)
        @current_user.followees << @post.user
    end
    
    #   render json: @post, include: [:user, comments: { include: :user }]
    if Post.find(params[:id])
      @post = Post.find(params[:id])
      @post.increment_views
      render json: @post.as_json(
          methods: [:image_url],
          include: [:user, :topic, { comments: { include: :user } }, { likes: { include: :user } }]
      )
    else
      render json: { message: 'Post not found for the given id' }
    end
    # render json: @post, include: [:user, :topic, :comments, :likes]
  end

  def create
    @post = Post.new(post_params)
    # @post.user_id = params[:post][:user_id]
    # @post.topic_id = params[:post][:topic_id]
    @post.user_id=current_user.id
    min_read_time=@post.calculate_reading_time(@post.description)
    if @post.save
      # Create a new post revision
      PostRevision.create(content: @post.description, post: @post, editor: @current_user)
        render json: @post.as_json(
      methods: [:image_url],  # Include the image_url method
      include: [:user, :topic]
    ), status: :created
    #   render json: @post, status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      # Create a new post revision
      PostRevision.create(content: @post.description, post: @post, editor: @current_user)
      render json: @post
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    render json: { message: 'Post deleted successfully' }
  end


#   //specific functionality of level 3
    def more_posts_by_author
        @post = Post.find(params[:id])
        author_id = @post.user_id
        posts = Post.where(user_id: author_id).where.not(id: @post.id)
        render json: posts, include: [:user, :topic, :comments, :likes]
    end

    def top_posts
        posts = Post.order(likes_count: :desc, comments_count: :desc, views: :desc).limit(10)
        # render json: posts, include: [:user , :topic, :comments, :likes]
        # render json: posts, include: [:user, :topic, { comments: { include: :user } }, { likes: { include: :user } }]
        # render json: posts, include: { user: {only: :name },topic: { only: :name },comments: {include: { user: { only: :name }}},
        #                             likes: { include: { user: { only: :name } } }}
        # *****getting only the imp data 
        custom_posts = []
        posts.each do |post|
            custom_post = {
            id: post.id,
            title: post.title,
            description: post.description,
            user_name: post.user.name,
            topic_name: post.topic.name,
            comments: [],
            likes: [],
            image_url: post.image_url
            }
            
            post.comments.each do |comment|
            custom_post[:comments] << {
                user_name: comment.user.name,
                content: comment.content
            }
            end
            
            post.likes.each do |like|
            custom_post[:likes] << {
                user_name: like.user.name
            }
            end
            
            custom_posts << custom_post
        end
        
        render json: custom_posts
    end

  private

  # def set_post
  #   @post = Post.find(params[:id])
  # end

  def post_params
    # params.require(:post).permit(:title,:description, :user_id,:topic_id,:min_read_time, :image)
    params.permit(:title,:description, :user_id,:topic_id, :image)
  end
end
