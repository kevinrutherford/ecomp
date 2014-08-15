class RevisionSummaryFromMetrics

  def initialize(metrics)
    @metrics = metrics
  end

  def sum_of_file_weights
    @metrics['complexity']['sum_of_file_weights']
  end

  def date
    @metrics['date']
  end

  def author
    @metrics['author']
  end

  def raw_data
    @metrics
  end

end