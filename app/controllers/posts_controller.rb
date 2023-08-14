class PostsController < ApplicationController
    before_action :authenticate_request, except: [:index]
    # before_action :authenticate_request, only: [:new, :create, :update, :destroy, :my_posts,:share_post]
    # before_action :set_post, only: [:show, :update, :destroy, :more_posts_by_author]

  def index
    posts = Post.includes(:user).all
    

    # Filter by author name
    if params[:user_id]
        user = User.find(params[:user_id])
        posts = user.posts
        # posts = posts.joins(:user_id).where("authors.name LIKE ?", "%#{params[:user_id]}%")
    end
  
    # Filter by published date
    if params[:date]
      date = Date.parse(params[:date]) rescue nil
      if date.nil?
        render json: { error: 'Invalid date format. Please provide date in yyyy-mm-dd format.' }, status: :unprocessable_entity
      else
        date = date.to_date 
      end
      # created_at=DateTime.parse(post.created_at.to_s).strftime("%y-%m-%d")
      # posts = posts.where("created_at >= ? AND created_at < ?", date, date + 1.day)
      posts = posts.where("DATE(created_at) >= ? AND DATE(created_at) < ?", date, date + 1.day)
      
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
                .order('commenets_count DESC')
  end
  post_data = posts.map do |post|
    {
      id: post.id,
      title: post.title,
      topic: post.topic.name,
      description: post.description,
      # image: post.image,
      likes_count: post.likes_count,
      comments_count: post.commenets_count,
      # published_at: post.published_at,
      views: post.views,
      read_time: post.min_read_time,
      author_name: post.user.name,
      published_at: DateTime.parse(post.created_at.to_s).strftime("%d-%m-%Y"),
      author_id: post.user.id
    }
end
    render json: post_data
    
  end

  def search
    if params[:search].present?
      search_query = params[:search].strip.downcase
      
      where_clause = "lower(title) LIKE '%"+search_query+"%' OR lower(topic) LIKE '%"+search_query+"%' OR lower(description) LIKE '%"+search_query+"%' OR lower(authors.name) LIKE '%"+search_query+"%'"
      # Find articles that match the search query in title, description, or tags
      @posts = Post.joins(:author).where(where_clause)
    else
      @posts = Post.all
    end
    
    post_data = @posts.map do |post|
        {
          id: post.id,
          title: post.title,
          topic: post.topic.name,
          description: post.description,
          image: post.image_url, # Use service_url to get the image URL
          published_at: post.created_at,
          author_name: post.user.name
        }
      end

    render json: post_data
  end

  def show
    
    #   render json: @post, include: [:user, comments: { include: :user }]
    if Post.find(params[:id])
        @post = Post.find(params[:id])
        if @post 
          if check_view_limit
              @post.increment_views    #increase the view_count of the post
              @post_view = PostView.find_by(user: @current_user, post: @post)
              if @post_view.nil?
                @post_view = PostView.create(user: @current_user, post: @post, viewed_at: Time.zone.now)
              end
              post=@post
              custom_posts = []
              custom_post = {
              id: post.id,
              title: post.title,
              description: post.description,
              author_name: post.user.name,
              topic_name: post.topic.name,
              likes_count: post.likes_count,
              comments_count: post.commenets_count,
              # views: post.views,
              read_time: post.min_read_time,
              
              published_at: DateTime.parse(post.created_at.to_s).strftime("%d-%m-%Y"),
              author_id: post.user.id,
              comments: [],
              likes: [],
              image: post.image_url
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
              render json: custom_posts, status: :ok
              # response_data = {
              #     post: @post,
              #     file_url: (@post&.image&.attached?) ? url_for(@post.image) : nil,
              #     comments: @post.comments,
              #     more_posts_by_user: more_posts_by_user
              # }
              # render json: response_data, status: :ok  
          else
              render json: { message:"views exhausted" }
          end
      else
          render json: { errors: "Post Not Found" }, status: :not_found
      end
    end
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
    # @user=User.find(params[:user_id])
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

#to share post to other through email
  def share_post
    @post = Post.find(params[:post_id])
    recipient_email = params[:recipient_email]
    message = params[:message]
    ShareListAndPostMailer.share_post_email(current_user, @post, recipient_email, message).deliver_now

    flash[:notice] = "Post shared successfully!"
    redirect_to @post
  end

  def my_posts
    # @post.user_id = current_user.id
    posts = Post.joins(:user).where(user_id: current_user.id)
    post_data = posts.map do |post|
      {
        id: post.id,
        title: post.title,
        topic: post.topic,
        description: post.description,
        image: post.image_url,
        published_at: post.created_at,
        author_name: post.user.name,
        author_id: post.user.id,
        likes_count: post.likes_count,
        comments_count: post.commenets_count
      }
    end

    render json: post_data,status: :ok

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

    def recommended_posts
      topic_id = params[:topic_id]
      posts_with_similar_topic = Post.where(topic_id: topic_id).order(likes_count: :desc)
      recommended_posts = posts_with_similar_topic.limit(5)
      render json: recommended_posts, status: :ok
    end

  private

  # def set_post
  #   @post = Post.find(params[:id])
  # end

  def post_params
    # params.require(:post).permit(:title,:description, :user_id,:topic_id,:min_read_time, :image)
    params.permit(:title,:description, :user_id,:topic_id, :image)
  end

  def check_view_limit
    daily_view_limit = get_daily_view_limit()
    start_of_day = Time.zone.now.beginning_of_day
    end_of_day = Time.zone.now.end_of_day

    user_todays_views = PostView.where(user_id: current_user.id, viewed_at: start_of_day..end_of_day)
    todays_view_count=user_todays_views.count
    todays_view_count < daily_view_limit
  end
  def get_daily_view_limit
    subscription = @current_user.subscription_plan

    if subscription.nil?
      daily_view_limit = 1
    else
      daily_view_limit = subscription.max_posts_per_day
    end
    daily_view_limit
  end




end
