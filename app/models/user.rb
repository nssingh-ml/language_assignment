class User < ApplicationRecord

    # // Set Up Enums for Subscription Tiers
    enum subscription: {
    free: 0,       # 0 corresponds to "free"
    tier1: 1,      # 1 corresponds to "tier1"
    tier2: 2,      # 2 corresponds to "tier2"
    tier3: 3,      # 3 corresponds to "tier3"
    tier4: 4       # 4 corresponds to "tier4"
  }

    has_many :posts, dependent: :destroy
    has_many :likes, dependent: :destroy
    has_many :comments, dependent: :destroy




    has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follower', dependent: :destroy
    has_many :followers, through: :follower_relationships, source: :follower

    has_many :followee_relationships, foreign_key: :user_id, class_name: 'Followee', dependent: :destroy
    has_many :followees, through: :followee_relationships, source: :followee

    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true, length: { minimum: 6 }

    has_secure_password


    def already_liked?(post)
        likes.exists?(post: post)
      end
    
    def already_following?(user)
    followees.exists?(followee: user)
    end


    def can_view_post?(post)
        case subscription
        when "free", "tier1"
          true  # Free and tier1 users can view all posts
        when "tier2"
          user_posts_today = posts.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
          if user_posts_today < 3
            true
          else
            # Add a warning message here for the user
            "You have reached your limit of 3 posts for today. To view more posts, consider upgrading to a higher tier."
          end
        when "tier3"
          user_posts_today = posts.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
          if user_posts_today < 5
            true
          else
            # Add a warning message here for the user
            "You have reached your limit of 5 posts for today. To view more posts, consider upgrading to a higher tier."
          end
        when "tier4"
          user_posts_today = posts.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
          if user_posts_today < 10
            true
          else
            # Add a warning message here for the user
            "You have reached your limit of 10 posts for today. To view more posts, consider upgrading to a higher tier."
          end
        else
          false # Default case: no access
        end
      end
    
end
