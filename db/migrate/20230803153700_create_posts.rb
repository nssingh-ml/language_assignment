class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :description
      t.integer :commenets_count, default: 0
      t.integer :likes_count, default: 0
      t.integer :min_read_time, default: 0
      t.integer :views, default: 0
      t.references :user, null: false, foreign_key: true
      t.references :topic, null: false, foreign_key: true

      t.timestamps
    end
  end
end
