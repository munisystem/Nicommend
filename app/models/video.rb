class Video < ActiveRecord::Base
  def self.get_all_count()
    Video.all.count
  end

  def self.get_all_id()
    Video.all
  end

end
