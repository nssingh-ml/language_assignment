class CreateDrafts < ActiveRecord::Migration[7.0]
  def change
    create_table :drafts do |t|
      t.string :title
      t.integer :topic_id
      t.text :description
      t.string :image
      t.references :user, null: false, foreign_key: true
      t.references :topic, null: false, foreign_key: true

      t.timestamps
    end
  end
end
