class DeveloperBehaviourReport

  DELTA_CUTOFF_DAYS = 365

  def initialize(commits)
    @commits = commits
  end

  def raw_data
    recent = @commits.select {|c| DateTime.parse(c[:date]) > cutoff_date }
    group_by_author(recent[1..-1])
  end

  private

  def cutoff_date
    @cutoff_date ||= DateTime.parse(@commits[-1][:date]) - DELTA_CUTOFF_DAYS
  end

  def group_by_author(commits)
    commits.group_by {|commit| commit[:author] }.map do |author, commits|
      { author: author, commits: commits }
    end
  end

end
