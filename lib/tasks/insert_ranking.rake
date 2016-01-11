namespace :insert_ranking do
  desc 'ニコニコ動画のランキングから動画ID、コメント、形態素解析の結果で出てきたワードを挿入する'

  task :insert_videoid => :environment do
    nico = Niconico.new
    nico.login(ENV['NICO_MAIL'], ENV['NICO_PASS'])
    ranking = nico.get_ranking_info('daily', 'all')
    ranking.each do |video|
      video.slice!("http://www.nicovideo.jp/watch/")
      if video.match(/sm./)
        Video.create(:video => video)
      end
    end
  end

end
