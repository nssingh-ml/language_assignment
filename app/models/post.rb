class Post < ApplicationRecord
  belongs_to :user
  belongs_to :topic
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :post_topics
  # has_many :topics, through: :post_topics

  has_one_attached :image

  def increment_likes_count
    self.likes_count += 1
    save
  end

  def increment_commenets_count
    # if self.commenets_count>=0
      self.commenets_count += 1
    # end
    save
  end

  def decrement_likes_count
    if self.likes_count>=0
      self.likes_count -= 1
    end
    save
  end

  def decrement_comments_count
    self.commenets_count -= 1
    save
  end

  def increment_views
    # self.views_count += 1
    self.views+=1
    save
  end

  def image_url
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    else
      nil
    end
  end



end
