require_relative 'file_revision'
require_relative 'revision_summary'
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
    revisions = @repo.all_revisions_oldest_first
    summaries = revisions.map {|rev| update_with_complexity(rev) }
    summaries = record_complexity_deltas(summaries)
    @report.update('current_files', CurrentHotspotsReport.new(@repo, @glob))
    @report.update('commits', ComplexityTrendReport.new(summaries))
    @report.update('recent_commits_by_author', DeveloperBehaviourReport.new(summaries))
    @repo.reset
    $stderr.puts ''
  end

  private

  def record_complexity_deltas(summaries)
    summaries.each_with_index do |summary, i|
      delta = summary.sum_of_file_weights - (i > 0 ? summaries[i-1].sum_of_file_weights : 0)
      summary.set_delta(delta)
    end
    summaries
  end

  def update_with_complexity(rev)
    files = @repo.files_in_revision(rev, @glob)
    rev[:complexity] = summarise_all_files(files)
    $stderr.print '.'
    RevisionSummary.new(rev)
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
