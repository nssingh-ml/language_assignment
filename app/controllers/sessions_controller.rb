class SessionsController < ApplicationController
    skip_before_action :authenticate_request
    # before_action :authenticate_request

    def create
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        token = JwtService.encode({ user_id: user.id })
        render json: { token: token }
      else
        render json: { error: "Invalid credentials" }, status: :unauthorized
      end
    end
    # def create
    #     user = User.find_by(email: params[:email])
    
    #     if user && user.authenticate(params[:password])
    #       session[:user_id] = user.id
    #       csrf_token = form_authenticity_token
    #       render json: { message: 'Login successful', user: user }
    #     else
    #       render json: { message: 'Invalid email or password' }, status: :unauthorized
    #     end
    # end
    
    def destroy
      session[:user_id] = nil
      render json: { message: 'Logout successful' }
    end
end
