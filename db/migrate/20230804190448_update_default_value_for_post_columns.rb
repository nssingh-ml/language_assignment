class UpdateDefaultValueForPostColumns < ActiveRecord::Migration[7.0]
  def change
    change_column_default :posts, :commenets_count, from: nil, to: 0
    change_column_default :posts, :likes_count, from: nil, to: 0
    change_column_default :posts, :views, from: nil, to: 0
    change_column_default :posts, :min_read_time, from: nil, to: 0
  end
end
