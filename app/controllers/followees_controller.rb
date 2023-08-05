class FolloweesController < ApplicationController
    before_action :set_followee, only: :destroy

    def create
        followee = current_user.followees.build(followee_id: params[:followee_id])
        if followee.save
        render json: followee, status: :created
        else
        render json: { errors: followee.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        @followee.destroy
        render json: { message: 'Followee removed successfully' }
    end

    private

    def set_followee
        @followee = current_user.followees.find_by(followee_id: params[:id])
        render json: { error: 'Followee not found' }, status: :not_found unless @followee
    end
end
