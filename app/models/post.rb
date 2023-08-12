class Post < ApplicationRecord
  belongs_to :user
  belongs_to :topic
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_and_belongs_to_many :lists
  has_many :saved_posts

  has_many :post_revisions

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

  def calculate_reading_time(content)
    words_per_minute = 20
    words = content.split.size
    # (words.to_f / words_per_minute).ceil
    reading_time = (words.to_f / words_per_minute).ceil
    reading_time = 1 if reading_time.zero? # Set to 1 if reading time is 0
    reading_time
  end

end
