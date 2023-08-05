class UsersController < ApplicationController
    # skip_before_action :authenticate_request, only: [:create, :update, :purchase_subscription]
    skip_before_action :authenticate_request
    # before_action :authenticate_request!, only: [:purchase_subscription]
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
    user = User.find(params[:user_id])
    # user=@user
    posts = user.posts
    render json: posts
  end

  def destroy
    @user.destroy
    render json: { message: 'User deleted successfully' }
  end



  def purchase_subscription
    subscription = params[:subscription] # Assuming subscription is passed as a parameter
    # user = @current_user # Assuming you have a method to fetch the current user
  
    if @user.update(subscription: subscription)
      render json: { message: "Subscription purchased successfully." }
    else
      render json: { error: "Failed to purchase subscription." }, status: :unprocessable_entity
    end
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.permit(:name, :password, :email, :mob_no, :about)
    # params.require(:post).permit(:name, :password, :email, :mob_no, :about)
    # require(:post)
  end
end
