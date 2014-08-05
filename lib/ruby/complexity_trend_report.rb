class ComplexityTrendReport

  def initialize(summaries)
    @summaries = summaries
  end

  def raw_data
    @summaries.map {|s| s.raw_data }
  end

end
