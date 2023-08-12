class CreatePostRevisions < ActiveRecord::Migration[7.0]
  def change
    create_table :post_revisions do |t|
      t.text :content
      t.references :post, null: false, foreign_key: true
      t.datetime :created_at
      t.references :editor, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
