require_relative 'file_revision'
require_relative 'developer_behaviour_report'

class BesMetrics

  def initialize(repo, report, glob='*/**/*.*')
    @repo = repo
    @report = report
    @glob = glob
  end

  def collect
    @repo.reset
    commits = @repo.all_revisions_oldest_first
    update_with_complexity(commits)
    commits = record_complexity_deltas(commits)
    @report.update('current_files', files_report(@glob))
    @report.update('commits', commits)
    @report.update('recent_commits_by_author', DeveloperBehaviourReport.new(commits).raw_data)
    @repo.reset
    $stderr.puts ''
  end

  private

  def record_complexity_deltas(commits)
    commits.each_with_index do |commit, i|
      delta = commit[:complexity][:sum_of_file_weights] - (i > 0 ? commits[i-1][:complexity][:sum_of_file_weights] : 0)
      commit[:complexity][:delta_sum_of_file_weights] = delta
    end
    commits
  end

  def update_with_complexity(commits)
    commits.each do |commit|
      files = @repo.files_in_revision(commit, @glob)
      commit[:complexity] = summarise_all_files(files)
      $stderr.print '.'
    end
  end

  def summarise_all_files(files)
    file_reports = files.map(&:complexity_report)
    weights = file_reports.empty? ? [0] : file_reports.map {|rpt| rpt['weight'] }
    weight_sum = weights.inject(:+)
    {
      sum_of_file_weights: weight_sum,
      max_of_file_weights: weights.max,
      mean_of_file_weights: (weight_sum.to_f / weights.length).round(2)
    }
  end

  def files_report(files_glob)
    @repo.current_files(files_glob).map(&:complexity_report)
  end

end
