class PaymentsController < ApplicationController
  before_action :authenticate_request
  Stripe.api_key = 'sk_test_51NeHfNSEGkcbRibwwjrOyg5Uh0uwwQdOFH6803tEWslsO71LY10nNuYx09AOBl6dF5rYGZOSIMifEhcBmeyOTTGw00Ap1Tfrru'
    def create
        # Get the current user
        user = current_user
    
        # # # Tokenize the payment information
        # token = Stripe::Token.create({
        #   card: {
        #       number: '4242424242424242',
        #     # number: '4000003560000008',
        #     exp_month: 12,
        #     exp_year: 2023,
        #     cvc: '123'
        #   }
        # })
        # when user make payment it passed the stripe token for testing this is not needed
        # token = params[:stripeToken]
        # token_id=token.id
        # test_token = "tok_in"      #by default test token for india but it should follow all the rbi guide lines
        amount=params[:amount]
    

        charge = Stripe::PaymentIntent.create({
          amount: amount,
          currency: 'usd',
          description: 'Example Charge',
          payment_method_types: ['card'],
          payment_method: 'pm_card_visa',
          confirm: true,
          # source: token,  #uncomment for real user to pass token
      })
      charge.status = 'succeeded'     #here we set status manually but we can directly check the status when done by real users
        # Handle successful payment
        if charge.status     
            payment_amount = amount.to_i # Assuming you pass the payment amount in the request
            subscription_tier = determine_subscription_plan(payment_amount) # Implement this logic

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
        flash[:success] = "Payment successful!"
      rescue Stripe::CardError => e
        render json: { message: e.message }, status: :unprocessable_entity
      end

      private
      
      def determine_subscription_plan(payment_amount)
        SubscriptionPlan.find_by(amount: payment_amount)
        # case payment_amount
        # when 3
        #   "tier1"
        # when 5
        #   "tier2"
        # when 10
        #   "tier3"
        # else
        #   0 # Subscription tier not determined
        # end
      end

      def payment_params
          params.permit(
              :stripeToken,   #not needed for testing
              :amount
              )
      end
end
