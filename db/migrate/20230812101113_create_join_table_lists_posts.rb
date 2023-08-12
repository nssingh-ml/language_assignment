class CreateJoinTableListsPosts < ActiveRecord::Migration[7.0]
  def change
    create_join_table :lists, :posts do |t|
      # t.index [:list_id, :post_id]
      # t.index [:post_id, :list_id]
    end
  end
end
