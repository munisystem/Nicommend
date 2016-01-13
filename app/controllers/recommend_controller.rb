class RecommendController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def special_words
    render :text => Word.get_video_tfidf(params[:id]).first(20)
  end
 end