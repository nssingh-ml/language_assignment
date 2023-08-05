class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session, if: -> { request.format.json? }
    # before_action :authenticate_user
    before_action :authenticate_request

    private



    def authenticate_request
        token = request.headers['Authorization']
        user_data = JwtService.decode(token)
        @current_user = User.find(user_data['user_id']) if user_data
        render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
      end

    # def authenticate_user
    #     @current_user ||= User.find_by(id: session[:user_id])
    # end
end
