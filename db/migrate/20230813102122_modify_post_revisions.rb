class ModifyPostRevisions < ActiveRecord::Migration[7.0]
  def change
    # Add the 'editor' reference
    add_reference :post_revisions, :editor, foreign_key: { to_table: :users }
    
    # # Remove the existing references
    # remove_reference :post_revisions, :post, foreign_key: true
    # remove_reference :post_revisions, :editor, foreign_key: { to_table: :users }

    # # Add foreign key for user_id
    # add_foreign_key :post_revisions, :users, column: :user_id

    # # Add new columns
    # add_column :post_revisions, :user_id, :integer
    # add_column :post_revisions, :title, :string
    # add_column :post_revisions, :post_id, :integer

    
  end
end
