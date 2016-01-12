require 'json'
require 'open-uri'
require 'net/https'
require 'net/http'
require 'uri'
require 'rexml/document'

class Niconico

  def login(mail, password)

    https = Net::HTTP.new('secure.nicovideo.jp', 443)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = https.start{|https|
      https.post('/secure/login?site=niconico', "mail=#{mail}&password=#{password}")
    }

    user_session = nil
    response.get_fields('set-cookie').each {|cookie|
      cookie.split('; ').each {|param|
        pair = param.split('=')
        if pair[0] == 'user_session' then
          user_session = pair[1] if pair[1] != 'deleted'
          break
        end
      }
      break unless user_session.nil?
    }
    @session_id = user_session
    return user_session
  end

  def get_flv_info(movie_id)
    host = 'flapi.nicovideo.jp'
    path = "/api/getflv/#{movie_id}"

    response = Net::HTTP.new(host).start { |http|
      request = Net::HTTP::Get.new(path)
      request['cookie'] = "user_session=#{@session_id}"
      http.request(request)
    }

    flv_info = {}
    response.body.split('&').each do |st|
      stt = st.split('=')
      flv_info[stt[0].to_sym] = stt[1]
    end
    flv_info[:ms] =~ /(http%3A%2F%2Fmsg\.nicovideo\.jp%2F)(.*?)(%2Fapi%2F)/
    flv_info[:msg] = $2

    return flv_info
  end

  def get_movie_info(movie_id, max_num = 1000)
    flv_info       = get_flv_info(movie_id)
    msg_server_url = URI.unescape( flv_info[:ms] ).gsub("/api/", "")
    thread_id      = flv_info[:thread_id]
    movie_info_url = "#{msg_server_url}/api.json/thread?version=20090904&thread=#{thread_id}&res_from=-#{max_num}"
    JSON.load( open(movie_info_url).read )
  end

  # 与えられた動画IDのコメント情報を返す
  def get_comments_info(movie_id, max_num = 1000)
    movie_info =  get_movie_info(movie_id, max_num)
    comments_info = []
    movie_info.each do |v|
      comments_info << v["chat"] if v.has_key?("chat")
    end
    comments_info
  end

  def extract_comments(infos)
    infos.map { |info| info["content"] }
  end

  def get_comments(movie_id, max_num = 1000)
    comments_info = get_comments_info(movie_id, max_num)
    extract_comments(comments_info)
  end

  def get_ranking_info(span, category)
    path = "http://www.nicovideo.jp/ranking/fav/#{span}/#{category}?rss=2.0"

    uri = URI.parse path
    res = Net::HTTP.get uri

    doc = REXML::Document.new res
    movies = []
    doc.elements.each('/rss/channel/item/link'){|e| movies << e.text}
    return movies
  end
end
