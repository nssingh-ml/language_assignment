class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session, if: -> { request.format.json? }
    # before_action :authenticate_user
    before_action :authenticate_request

    # private



    def authenticate_request
      token = request.headers['Authorization']&.split(' ')&.last
      begin
      decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256')
      user_id = decoded_token.first['user_id']
      # user_id = decoded_token[0]['user_id']
      @current_user = User.find(user_id)
      rescue JWT::DecodeError, JWT::VerificationError, ActiveRecord::RecordNotFound
      render json: { error: 'Invalid or missing token' }, status: :unauthorized
      end
        # token = request.headers['Authorization']
        # user_data = JwtService.decode(token)
        # @current_user = User.find(user_data['user_id']) if user_data
        # render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
    end

    def current_user
      @current_user
    end

    # def authenticate_user
    #     @current_user ||= User.find_by(id: session[:user_id])
    # end
end
