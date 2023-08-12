class UsersController < ApplicationController
    skip_before_action :authenticate_request, only: [:new, :create, :update, :purchase_subscription]
    # skip_before_action :authenticate_request
    # before_action :authenticate_request, only: [:purchase_subscription]
    before_action :authenticate_request, only: [:index, :show, :purchase_subscription]
    before_action :set_user, only: [:show, :update, :destroy, :purchase_subscription]

  def index
    users = User.all
    render json: users
  end

  def show
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

    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def my_posts
    # user = User.find( @current_user.id)
    @user=current_user
    posts = @user.posts
    render json: posts
  end

  def destroy
    @user.destroy
    render json: { message: 'User deleted successfully' }
  end



  def purchase_subscription

    payment_amount = params[:payment_amount] # Amount paid by the user
    subscription_tier = determine_subscription_tier(payment_amount) # Implement this logic

    if subscription_tier.present?
      stripe_subscription = create_stripe_subscription(subscription_tier) # Implement this logic

      if stripe_subscription.present?
        if @user.update(subscription: subscription_tier, stripe_subscription_id: stripe_subscription.id)
          render json: { message: "Subscription purchased successfully." }
        else
          render json: { error: "Failed to purchase subscription." }, status: :unprocessable_entity
        end
      else
        render json: { error: "Failed to create Stripe subscription." }, status: :unprocessable_entity
      end
    else
      render json: { error: "Invalid payment amount." }, status: :unprocessable_entity
    end

    # subscription = params[:subscription] # Assuming subscription is passed as a parameter
    # # user = @current_user # Assuming you have a method to fetch the current user
  
    # if @user.update(subscription: subscription)
    #   render json: { message: "Subscription purchased successfully." }
    # else
    #   render json: { error: "Failed to purchase subscription." }, status: :unprocessable_entity
    # end
  end


  def save_for_later_add
    post = Post.find(params[:post_id])

    if !@current_user.saved_posts.exists?(post.id)
      @current_user.saved_posts.create(post: post)
      render json: { message: "Post saved for later successfully" }, status: :ok
    else
      render json: { message: "Post Already Saved" }, status: :unprocessable_entity
    end
  end

  def show_all_saved
    saved_posts = @current_user.saved_posts.includes(post: :author)
    saved_data = saved_posts.map do |save_for_later|
      post = save_for_later.post
      {
        save_for_later_id: save_for_later.id,
        post_id: post.id,
        post_title: post.title,
        topic: post.topic,
        featured_image: post.featured_image,
        text: post.text,
        author_name: post.author.name,
        likes_count: post.likes_count,
        comments_count: post.comments_count
      }
    end
    render json: saved_data, status: :ok
  end


  private



  def determine_subscription_tier(payment_amount)
    case payment_amount
    when 3
      "tier1"
    when 5
      "tier2"
    when 10
      "tier3"
    else
      nil # Subscription tier not determined
    end
  end

  def create_stripe_subscription(subscription_tier)
    # Call the Stripe API to create a subscription
    stripe_subscription = Stripe::Subscription.create(
      customer: @current_user.stripe_customer_id,
      items: [{ plan: subscription_tier }]
    )
    stripe_subscription
   rescue Stripe::StripeError => e
    nil
  end

  def set_user
    # @user=@current_user
    @user = User.find(params[:id])
  end

    def user_params
      params.permit(:name, :password, :email, :mob_no, :about)
      # params.require(:post).permit(:name, :password, :email, :mob_no, :about)
      # require(:post)
    end
end
# end
