namespace :insert_db do
  desc 'ニコニコ動画のランキングから動画ID、コメント、形態素解析の結果で出てきたワードを挿入する'

  task :insert_ranking_comment => :environment do
    nico = Niconico.new
    nico.login(ENV['NICO_MAIL'], ENV['NICO_PASS'])
    ranking = nico.get_ranking_info('daily', 'all')
    ranking.each do |video|
      video.slice!("http://www.nicovideo.jp/watch/")
      if video.match(/sm./)
        comments = nico.get_comments(video).compact.reject(&:empty?)
        Video.create(:video => video, :comment => comments.count)

        nm = Natto::MeCab.new
        words = []
        comments.each do |comment|
          nm.parse(comment) do |n|
            if /^名詞/ =~ n.feature.split(/,/)[0] then
              words << n.surface
            end
          end
        end
        lists = words.each_with_object(Hash.new(0)) {|e, h| h[e] += 1 }
        lists.each do |key, value|
          Word.create(:video => video, :word => key, :item => value)
        end
      end
    end
  end

  task :test_tfidf => :environment do
    nico = Niconico.new
    nico.login(ENV['NICO_MAIL'], ENV['NICO_PASS'])
    VIDEO_ID = 'sm19011429'
    comments = nico.get_comments(VIDEO_ID).compact.reject(&:empty?)
    tfidf = Tfidf.new
    videos = Video.all.count

    nm = Natto::MeCab.new
    words = []
    comments.each do |comment|
      nm.parse(comment) do |n|
        if /^名詞/ =~ n.feature.split(/,/)[0] then
          words << n.surface
        end
      end
    end
    words_all = words.count
    lists = words.each_with_object(Hash.new(0)) {|e, h| h[e] += 1 }
    tfidf_hash = Hash.new
    lists.each do |key, value|
      tf = value / words_all.to_f
      df = Word.where(:word => key).count
      num = tfidf.get_tfidf(tf, df, videos)
      tfidf_hash.store(key, num)
    end
    tfidf_sort = Hash[tfidf_hash.sort_by{ |_, v| -v }]
    p tfidf_sort.first(100)


  end

end
