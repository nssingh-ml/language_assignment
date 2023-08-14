class CreatePostViews < ActiveRecord::Migration[7.0]
  def change
    create_table :post_views do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :post, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :viewed_at

      t.timestamps
    end
  end
end
