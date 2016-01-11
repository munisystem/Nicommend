class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :video
      t.string :word

      t.timestamps null: false
    end
  end
end
