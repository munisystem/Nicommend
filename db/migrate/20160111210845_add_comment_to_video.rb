class AddCommentToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :comment, :integer
  end
end
