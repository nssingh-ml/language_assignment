class PaymentsController < ApplicationController
    def create
        # Get the current user
        user = current_user
    
        # # Tokenize the payment information
        # token = Stripe::Token.create({
        #   card: {
        #     number: '4000003560000008',
        #     exp_month: 12,
        #     exp_year: 2023,
        #     cvc: '123'
        #   }
        # })

        # # token = params[:stripeToken]
        # token_id=token.id
        # test_token = "tok_in"
        amount=params[:amount]
    

        charge = Stripe::PaymentIntent.create({
          amount: amount,
          currency: 'usd',
          description: 'Example Charge',
          payment_method: 'pm_card_visa',
          # source: token
      })
        # Handle successful payment
        if charge.status = "succeeded"
            payment_amount = amount.to_i # Assuming you pass the payment amount in the request
            subscription_tier = determine_subscription_tier(payment_amount) # Implement this logic

            if subscription_tier.present?
                # current_user.subscription=subscription_tier
                current_user.update(subscription: subscription_tier)
                render json: { message: 'Payment successful. Subscription tier updated.',user: current_user}
                # render json: current_user;
            else
                render json: { message: 'Payment successful. Subscription tier not updated.' }, status: :unprocessable_entity
            end

        else
          
          render json: { message: 'Payment failed'}, status: :unprocessable_entity
        end
        flash[:success] = "Payment successful!"
      rescue Stripe::CardError => e
        render json: { message: e.message }, status: :unprocessable_entity
      end

      private
      
      def determine_subscription_tier(payment_amount)
        # if payment_amount<=3
        #   "tier1"
        # elsif payment_amount<=5
        #   "tier2"
        # elsif payment_amount<=10
        #   "tier3"
        # else
        #   0
        # end
        case payment_amount
        when 3
          "tier1"
        when 5
          "tier2"
        when 10
          "tier3"
        else
          0 # Subscription tier not determined
        end
      end

      def payment_params
          params.permit(
              :stripeToken,   #not needed for testing
              :amount
              )
      end
end
