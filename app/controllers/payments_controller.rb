class PaymentsController < ApplicationController
  # skip_before_action :authenticate_request
  skip_before_action :authenticate_request, only: :payment_test
  
  Stripe.api_key = 'sk_test_51NeHfNSEGkcbRibwwjrOyg5Uh0uwwQdOFH6803tEWslsO71LY10nNuYx09AOBl6dF5rYGZOSIMifEhcBmeyOTTGw00Ap1Tfrru'
    def create
        # Get the current user
        user = current_user
    
        
        # when user make payment it passed the stripe token for testing this is not needed
        # token = params[:stripeToken]
        token = "tok_in"      #by default test token for india but it should follow all the rbi guide lines
        amount=params[:amount]

        # use this for real payment for testing i used payment_method: 'pm_card_visa'
        charge = Stripe::PaymentIntent.create(
          amount: amount,
          currency: 'usd',   
          payment_method_types: ['card'],
          payment_method: 'pm_card_visa',
          confirm: true,
          # source: token
        )
        # Handle successful payment
        if charge.status     
            payment_amount = amount.to_i # Assuming you pass the payment amount in the request
            subscription_tier = determine_subscription_plan(payment_amount)  

            if subscription_tier.present?
                # update subscription to user
                current_user.update_column(:subscription_plan_id, subscription_tier.id)  
                render json: { message: 'Payment successful. Subscription plan updated.',user: current_user}
                # render json: current_user;
            else
                render json: { message: 'Payment successful. Subscription plan not updated.' }, status: :unprocessable_entity
            end

        else
          
          render json: { message: 'Payment failed',stauts:charge.status}, status: :unprocessable_entity
        end
        # flash[:success] = "Payment successful!"
      rescue Stripe::CardError => e
        render json: { message: e.message }, status: :unprocessable_entity
      end

      def payment_test
        # This is an empty action; it will automatically render the payments.html.erb view
        render 'payments'
      end

      private
      
      def determine_subscription_plan(payment_amount)
        SubscriptionPlan.find_by(amount: payment_amount)
      end

      def payment_params
          params.permit(
              :stripeToken,   #not needed for testing
              :amount
              )
      end
end
