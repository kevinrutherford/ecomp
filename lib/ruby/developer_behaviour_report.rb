require 'date'

class DeveloperBehaviourReport

  DELTA_CUTOFF_DAYS = 365

  def initialize(commits)
    @commits = commits
  end

  def raw_data
    recent = @commits.select {|commit| is_recent?(commit) }
    group_by_author(recent[1..-1])
  end

  private

  def cutoff_date
    @cutoff_date ||= DateTime.parse(@commits[-1][:date]) - DELTA_CUTOFF_DAYS
  end

  def is_recent?(commit)
    DateTime.parse(commit[:date]) > cutoff_date
  end

  def group_by_author(commits)
    commits.group_by {|commit| commit[:author] }.map do |author, commits|
      { author: author, commits: commits }
    end
  end

end
