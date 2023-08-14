class CreateSubscriptionPlans < ActiveRecord::Migration[7.0]
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.integer :amount
      t.integer :max_posts_per_day

      t.timestamps
    end
  end
end
