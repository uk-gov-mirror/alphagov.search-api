module Search::RelevanceHelpers
  def self.ltr_enabled?
    true
    # ENV["ENABLE_LTR"].present? && ENV["ENABLE_LTR"] == "true"
  end
end
