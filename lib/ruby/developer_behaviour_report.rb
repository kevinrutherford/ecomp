class DeveloperBehaviourReport

  DELTA_CUTOFF_DAYS = 365

  def initialize(commits)
    @commits = commits
  end

  def raw_data
    recent = @commits.select {|c| DateTime.parse(c[:date]) > cutoff_date }
    recent = record_complexity_deltas(recent)
    group_by_author(recent[1..-1])
  end

  private

  def cutoff_date
    @cutoff_date ||= DateTime.parse(@commits[-1][:date]) - DELTA_CUTOFF_DAYS
  end

  def record_complexity_deltas(commits)
    commits.each_with_index do |commit, i|
      delta = commit[:complexity][:sum_of_file_weights] - (i > 0 ? commits[i-1][:complexity][:sum_of_file_weights] : 0)
      commit[:complexity][:delta_sum_of_file_weights] = delta
    end
    commits
  end

  def group_by_author(commits)
    commits.group_by {|commit| commit[:author] }.map do |author, commits|
      { author: author, commits: commits }
    end
  end

end
