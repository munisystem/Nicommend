class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :video

      t.timestamps null: false
    end
  end
end
