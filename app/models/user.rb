class User < ApplicationRecord

  #   # // Set Up Enums for Subscription Tiers
  #   enum subscription: {
  #   free: 0,       # 0 corresponds to "free"
  #   tier1: 1,      # 1 corresponds to "tier1"
  #   tier2: 2,      # 2 corresponds to "tier2"
  #   tier3: 3,      # 3 corresponds to "tier3"
  #   tier4: 4       # 4 corresponds to "tier4"
  # }

    has_many :posts, dependent: :destroy
    has_many :likes, dependent: :destroy
    has_many :comments, dependent: :destroy

    has_many :lists
    has_many :saved_posts
    has_many :drafts

    # has_many :post_revisions, foreign_key: 'editor_id'
    has_many :post_revisions, through: :posts
    belongs_to :subscription_plan, optional: true

    has_many :post_views
    has_many :viewed_posts, through: :post_views, source: :post



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
    
end
