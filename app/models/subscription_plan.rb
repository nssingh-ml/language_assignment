class SubscriptionPlan < ApplicationRecord
    # validates :amount, presence: true
    # validates :max_posts_per_day, presence: true
    has_many :users
  end