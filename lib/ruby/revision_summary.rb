class RevisionSummary

  def initialize(rev)
    @rev = rev
  end

  def sum_of_file_weights
    @rev[:complexity][:sum_of_file_weights]
  end

  def set_delta(delta)
    @rev[:complexity][:delta_sum_of_file_weights] = delta
  end

  def date
    @rev[:date]
  end

  def author
    @rev[:author]
  end

  def raw_data
    @rev
  end

end
