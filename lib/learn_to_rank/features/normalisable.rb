module LearnToRank::Features::Normalisable
  # Rescaling technique used here (min-max normalization)
  def normalise_minmax(val, min, max)
    return val
    # (val - min) / (max - min)
  end

  # Feature hashing technique used here
  # https://en.wikipedia.org/wiki/Feature_hashing
  def normalise_str(str)
    return 0.0 unless str && str.length.positive?
    # TODO remove hack
    Float(["0.", Digest::MD5.hexdigest(str).to_i(16).to_s].join)
  end
end
