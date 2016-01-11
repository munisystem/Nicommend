class AddItemToWord < ActiveRecord::Migration
  def change
    add_column :words, :item, :integer
  end
end
