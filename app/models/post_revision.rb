class PostRevision < ApplicationRecord
  belongs_to :post
  belongs_to :editor, class_name: 'User', foreign_key: 'editor_id'
  # belongs_to :user, class_name: 'User', foreign_key: 'user_id'
end
