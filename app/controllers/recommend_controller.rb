class RecommendController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def special_words
    video_tfidf = Word.get_video_tfidf(params[:id]).first(100)
    render :text => Word.get_recommend(video_tfidf).first(5)
  end
 end