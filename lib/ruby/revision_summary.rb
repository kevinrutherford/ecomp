class RevisionSummary

  def initialize(rev, repo, glob)
    @rev = rev
    @repo = repo
    @glob = glob
    @summarised = false
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

  private

  def summarise
    return if @summarised
    puts("Summarising revision: #{@rev[:date]} (#{@rev[:ref]})")
    files = @repo.files_in_revision(@rev, @glob)
    @rev[:complexity] = summarise_all_files(files)
    @summarised = true
  end

  def summarise_all_files(files)
    file_reports = files.generate_reports
    weights = []
    if (file_reports.empty?)
      weights.push(0)
    else
      file_reports.each do |rpt|
        if rpt.nil?
          puts "There is nothing to report"
        else
          weights.push(rpt['weight'])
        end
      end
    end
    weight_sum = weights.inject(:+)
    {
      sum_of_file_weights: weight_sum,
      max_of_file_weights: weights.max,
      mean_of_file_weights: (weight_sum.to_f / weights.length).round(2)
    }
  end
end
