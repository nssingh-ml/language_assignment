class FollowersController < ApplicationController
    before_action :set_follower, only: :delete

    def create
        user=User.find(params[:follower_id])
        # follower = current_user.followers.build(follower_id: params[:follower_id])
        current_user.followers << user
        # if follower.save
        render json: {message:'folllows successfully',follows:current_user.followers}, status: :created
        # else
        # render json: { errors: follower.errors.full_messages }, status: :unprocessable_entity
        # end
    end


    def show_all
        render json: current_user.followers
    end
    def delete
        @follower.destroy
        render json: { message: 'Unfollowed successfully' }
    end

    private

    def set_follower
        @follower = current_user.followers.find_by(id: params[:id])
        render json: { error: 'Follower not found' }, status: :not_found unless @follower
    end
end
