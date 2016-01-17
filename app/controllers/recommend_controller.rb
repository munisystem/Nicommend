class RecommendController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
  end

  def show_recommend
    #@video_tfidf = Word.get_video_tfidf(params[:id]).first(100)
    @user_send_video = params[:id]
    @video_tfidf = Word.get_video_tfidf(@user_send_video).first(100)
    @recommend = Word.get_recommend(@video_tfidf).first(3)
  end
 end