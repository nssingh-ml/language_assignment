class UsersController < ApplicationController
    skip_before_action :authenticate_request, only: [:new, :create, :purchase_subscription]
    before_action :authenticate_request, only: [:index, :show, :purchase_subscription, :update,:save_for_later, :my_details, :show_all_saved]
  
  #uncommment it if you are using routes through resources
  # def index
  #   users = User.all
  #   render json: users
  # end

  def all_users
    users =  User.all.select(:id,:name,:about)
    render json: users, status: :ok
  end

  def show
    @user = User.find(params[:id])
    render json: @user, include: :posts
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    # @user = User.find(params[:id])
    @user=current_user
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # def my_posts
  #   # user = User.find( @current_user.id)
  #   @user=current_user
  #   posts = current_user.posts
  #   render json: posts
  # end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    render json: { message: 'User deleted successfully' }
  end

  def search_users
    if params[:search].present?
      search_query = params[:search].strip.downcase
      
      where_clause = "lower(name) LIKE '%"+search_query+"%'"
      # Find articles that match the search query in title, description, or tags
      users = User.where(where_clause).select(:id,:name)
    else
      users = User.all.select(:id,:name)
    end

    render json: users, status: :ok
  end



  def save_for_later
    post = Post.find(params[:post_id])

    if !@current_user.saved_posts.exists?(post.id)
      @current_user.saved_posts.create(post: post)
      render json: { message: "Post saved for later successfully" }, status: :ok
    else
      render json: { message: "Post Already Saved" }, status: :unprocessable_entity
    end
  end

  def show_all_saved
    saved_posts = @current_user.saved_posts.includes(post: :user)
    saved_data = saved_posts.map do |save_for_later|
      post = save_for_later.post
      {
        save_for_later_id: save_for_later.id,
        post_id: post.id,
        post_title: post.title,
        topic: post.topic.name,
        featured_image: post.image_url,
        description: post.description,
        author_name: post.user.name,
        likes_count: post.likes_count,
        comments_count: post.commenets_count
      }
    end
    render json: saved_data, status: :ok
  end

  def my_details
    # user = user.find(current_user.id)
    follower_count=current_user.followers.count
    @user = current_user.slice(:id,:name, :email, :about)
    render json: { user: @user, followers_count: follower_count }, status: :ok
    # render json: user,status: :ok
  end


  private

  # def set_user
  #   # @user=@current_user
  #   @user = User.find(params[:id])
  # end

    def user_params
      params.permit(:name, :password, :email, :mob_no, :about)
      # params.require(:post).permit(:name, :password, :email, :mob_no, :about)
      # require(:post)
    end
end
# end
