class Word < ActiveRecord::Base
  def self.get_video_tfidf(id)
    nico = Niconico.new
    nico.login(ENV['NICO_MAIL'], ENV['NICO_PASS'])
    comments = nico.get_comments(id).compact.reject(&:empty?)
    tfidf = Tfidf.new
    videos_count = Video.get_all_count()

    nm = Natto::MeCab.new
    words = []
    comments.each do |comment|
      nm.parse(comment) do |n|
        if /^名詞/ =~ n.feature.split(/,/)[0] then
          words << n.surface
        end
      end
    end
    words_count = words.count
    lists = words.each_with_object(Hash.new(0)) {|e, h| h[e] += 1 }
    tfidf_hash = Hash.new
    lists.each do |key, value|
      tf = value / words_count.to_f
      df = Word.get_word_count(key)
      num = tfidf.get_tfidf(tf, df, videos_count)
      tfidf_hash.store(key, num)
    end
    tfidf_sort = Hash[tfidf_hash.sort_by{ |_, v| -v }]
    return tfidf_sort.first(20)
  end

  def self.get_word_count(word)
    Word.where(:word => word).count
  end
end
