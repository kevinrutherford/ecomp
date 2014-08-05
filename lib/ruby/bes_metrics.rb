require_relative 'file_revision'
require_relative 'complexity_trend_report'
require_relative 'developer_behaviour_report'
require_relative 'current_hotspots_report'

class BesMetrics

  def initialize(repo, report, glob='*/**/*.*')
    @repo = repo
    @report = report
    @glob = glob
  end

  def collect
    @repo.reset
    commits = @repo.all_revisions_oldest_first
    summaries = update_with_complexity(commits)
    summaries = record_complexity_deltas(summaries)
    @report.update('current_files', CurrentHotspotsReport.new(@repo, @glob).raw_data)
    @report.update('commits', ComplexityTrendReport.new(summaries).raw_data)
    @report.update('recent_commits_by_author', DeveloperBehaviourReport.new(summaries).raw_data)
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
    commits
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

end
