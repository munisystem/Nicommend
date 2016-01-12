class Tfidf

  def get_tfidf(tf, df, num)
    return tf*(Math.log10(num / (df + 1) + 1)).to_f
  end

end