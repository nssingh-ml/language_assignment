class AddSubscriptionPlanToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :subscription_plan, foreign_key: true, default: SubscriptionPlan.find_by(name: 'free')&.id
  end
end
