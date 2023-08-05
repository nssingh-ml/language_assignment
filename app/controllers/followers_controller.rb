class FollowersController < ApplicationController
    before_action :set_follower, only: :destroy

    def create
        follower = current_user.followers.build(follower_id: params[:follower_id])
        if follower.save
        render json: follower, status: :created
        else
        render json: { errors: follower.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        @follower.destroy
        render json: { message: 'Unfollowed successfully' }
    end

    private

    def set_follower
        @follower = current_user.followers.find_by(follower_id: params[:id])
        render json: { error: 'Follower not found' }, status: :not_found unless @follower
    end
end
