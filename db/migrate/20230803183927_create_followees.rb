class CreateFollowees < ActiveRecord::Migration[7.0]
  def change
    create_table :followees do |t|
      t.integer :user_id
      t.integer :followee_id

      t.timestamps
    end
  end
end
