class Word < ActiveRecord::Base

  def self.get_video_tfidf(id)
    nico = Niconico.new
    nico.login(ENV['NICO_MAIL'], ENV['NICO_PASS'])
    comments = nico.get_comments(id).compact.reject(&:empty?)
    tfidf = Tfidf.new
    videos_count = Video.get_all_count()

    mecab = Morphological.new
    words = mecab.get_mophological(comments)
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
    return tfidf_sort.keys
  end

  def self.get_word_count(word)
    Word.where(:word => word).count
  end

  def self.get_video_word(video, word)
    Word.find_by_video_and_word(video, word)
  end

  def self.get_video_word_count(video)
    video_word_list = Word.where(:video => video)
    word_count = 0
    video_word_list.each do |word|
      word_count += word.item
    end
    return word_count
  end

  def self.get_recommend(words)
    tfidf = Tfidf.new
    videos_tfidf = Hash.new
    videos = Video.get_all_id()
    videos_count = Video.get_all_count()
    videos.each do |video|
      tfidf_hash = Hash.new
      id = video.video
      video_word_count = Word.get_video_word_count(id)
      words.each do |word|
        video_word = Word.get_video_word(id, word)
        if (video_word.nil?)
          tfidf_hash.store(word, 0)
          next
        end
        tf = video_word.item / video_word_count.to_f
        df = Word.get_word_count(word)
        num = tfidf.get_tfidf(tf, df, videos_count)
        tfidf_hash.store(word, num)
      end
      sum = 0
      tfidf_hash.each_value do |value|
        sum += value.to_f
      end
      videos_tfidf.store(id, sum)
    end
    videos_sort = Hash[videos_tfidf.sort_by{ |_, v| -v }]
    return videos_sort
  end

end
