class PaymentsController < ApplicationController
    def create
        # Get the current user
        user = current_user
    
        # Tokenize the payment information
        token = params[:stripeToken]
    
        # Create a Stripe customer with the token
        customer = Stripe::Customer.create(
          email: user.email,
          source: token
        )
    
        # Charge the customer
        charge = Stripe::Charge.create(
          customer: customer.id,
          amount: amount, # Amount in rupee
          description: 'Payment for Subscription',
          currency: 'usd'
        )
    
        # Handle successful payment
        if charge.paid
          # Update your application's logic here (e.g., mark order as paid)
        #   render json: { message: 'Payment successful' }
            payment_amount = params[:amount] # Assuming you pass the payment amount in the request
            subscription_tier = determine_subscription_tier(payment_amount) # Implement this logic

            if subscription_tier.present?
                @user.update(subscription: subscription_tier)
                render json: { message: 'Payment successful. Subscription tier updated.' }
            else
                render json: { message: 'Payment successful. Subscription tier not updated.' }, status: :unprocessable_entity
            end

        else
          render json: { message: 'Payment failed' }, status: :unprocessable_entity
        end
      rescue Stripe::CardError => e
        render json: { message: e.message }, status: :unprocessable_entity
      end

      private

      def payment_params
          params.permit(
              :stripeToken,
              :amount
              )
      end
end
