require_relative 'file_revision'
require_relative 'revision_summary'
require_relative 'revision_summary_from_metrics'
require_relative 'complexity_trend_report'
require_relative 'developer_behaviour_report'
require_relative 'current_hotspots_report'

class BesMetrics

  def initialize(repo, report, metrics_dao, max_revisions, glob='*/**/*.*')
    @repo = repo
    @report = report
    @metrics_dao = metrics_dao
    @glob = glob
    @max_revisions = max_revisions
  end

  def collect
    puts 'Gathering metrics...'
    find_and_analyse_new_revisions
    puts 'Creating reports...'
    @report.update('recent_commits_by_author', DeveloperBehaviourReport.new(get_all_summaries_from_metrics))
    @report.update('current_files', CurrentHotspotsReport.new(@repo, @glob))
    @repo.reset
    puts "...completed"
  end

  private

  def find_and_analyse_new_revisions
    latest_revision_metrics = @metrics_dao.get_latest_revision_metrics
    revision = find_oldest_unanalysed_revision(latest_revision_metrics)
    count = 0

    revisions_to_analyse = get_number_of_revisions_to_analyse(latest_revision_metrics)
    puts "There are #{revisions_to_analyse} revisions to analyse"

    while (not revision.nil? and (count < @max_revisions)) do
      puts "Analysing #{count + 1}/#{revisions_to_analyse}..."
      summary = record_complexity_delta(RevisionSummary.new(revision, @repo, @glob), latest_revision_metrics)
      @metrics_dao.add_revision_summary(summary)

      latest_revision_metrics = @metrics_dao.get_latest_revision_metrics
      revision = find_oldest_unanalysed_revision(latest_revision_metrics)
      count += 1
    end

    puts "...completed"
  end

  def get_number_of_revisions_to_analyse(latest_revision_metrics)
    all_revisions = @repo.all_revisions_oldest_first
    size = all_revisions.size

    if latest_revision_metrics.nil?
      return size
    end

    index = 0
    all_revisions.each do |revision|
      if revision[:ref] == latest_revision_metrics['ref']
        break
      end
      index += 1
    end

    number_to_analyse = size - index

    if @max_revisions < number_to_analyse
      @max_revisions
    else
      number_to_analyse
    end
  end

  def find_oldest_unanalysed_revision(latest_revision_metrics)
    @repo.reset
    all_revisions_oldest_first = @repo.all_revisions_oldest_first
    revision = nil
    if latest_revision_metrics.nil?
      revision = all_revisions_oldest_first.first
    elsif latest_revision_metrics['ref'] == all_revisions_oldest_first.last[:ref]
      puts 'Latest revision already analysed'
      revision = nil
    elsif latest_revision_metrics['ref'] == all_revisions_oldest_first.first[:ref]
      revision = all_revisions_oldest_first[1]
    else
      last_found = false
      all_revisions_oldest_first.each do |commit|
        if last_found
          revision = commit
          break
        end
        last_found = true if commit[:ref] == latest_revision_metrics['ref']
      end
    end

    revision
  end

  def record_complexity_delta(summary, latest_revision_metrics)
    delta = summary.sum_of_file_weights - (latest_revision_metrics.nil? ? 0 : latest_revision_metrics['complexity']['sum_of_file_weights'])
    summary.set_delta(delta)
    summary
  end

  def get_all_summaries_from_metrics
    summaries = Array.new
    @metrics_dao.get_all_revision_metrics.each do |metrics|
      summaries << RevisionSummaryFromMetrics.new(metrics)
    end
    summaries
  end

end
