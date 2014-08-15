class RevisionSummaryFromMetrics

  def initialize(metrics)
    @metrics = metrics
  end

  def sum_of_file_weights
    summarise
    @rev[:complexity][:sum_of_file_weights]
  end

  def set_delta(delta)
    summarise
    @rev[:complexity][:delta_sum_of_file_weights] = delta
  end

  def date
    @rev[:date]
  end

  def author
    @rev[:author]
  end

  def raw_data
    summarise
    @rev
  end

end