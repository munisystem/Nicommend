class Morphological

  def get_mophological(sentences)
    nm = Natto::MeCab.new
    words = []
    sentences.each do |comment|
      nm.parse(comment) do |n|
        if /^名詞/ =~ n.feature.split(/,/)[0] then
          words << n.surface
        end
      end
    end
    return words
  end

end
