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

end
