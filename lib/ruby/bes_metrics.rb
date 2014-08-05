require 'date'
require_relative 'ruby_source_file'
require_relative 'java_source_file'
require_relative 'developer_behaviour_report'
require_relative 'local_git_repo'

class BesMetrics

  def initialize(report, glob='*/**/*.*')
    @report = report
    @glob = glob
  end

  def collect
    @report.update('current_files', files_report(@glob))
    commits = repo.all_commits
    update_with_complexity(commits)
    commits = record_complexity_deltas(commits)
    @report.update('commits', commits)
    @report.update('recent_commits_by_author', DeveloperBehaviourReport.new(commits).raw_data)
    repo.reset
    $stderr.puts ''
  end

  private

  def repo
    if @repo.nil?
      @repo = LocalGitRepo.new
      @repo.reset
    end
    @repo
  end

  def record_complexity_deltas(commits)
    commits.each_with_index do |commit, i|
      delta = commit[:complexity][:sum_of_file_weights] - (i > 0 ? commits[i-1][:complexity][:sum_of_file_weights] : 0)
      commit[:complexity][:delta_sum_of_file_weights] = delta
    end
    commits
  end

  def complexity_report(path)
    report = case path
             when /.*\.rb$/
               RubySourceFile.new(path).complexity
             when /.*\.java$/
               JavaSourceFile.new(path).complexity
             end
    e = 1 + report[:num_dependencies]
    b = 1 + report[:num_branches]
    s = 1 + report[:num_superclasses]
    report['weight'] = b * e * s
    report[:churn] = repo.num_commits_involving(path)
    report
  end

  def update_with_complexity(commits)
    commits.each do |commit|
      repo.checkout(commit[:ref])
      $stderr.print '.'
      commit[:complexity] = summarise_all_files(@glob)
    end
  end

  def summarise_all_files(glob)
    files = Dir[glob]
    file_reports = files.map {|path| complexity_report(path) }
    weights = file_reports.empty? ? [0] : file_reports.map {|rpt| rpt['weight'] }
    weight_sum = weights.inject(:+)
    {
      sum_of_file_weights: weight_sum,
      max_of_file_weights: weights.max,
      mean_of_file_weights: (weight_sum.to_f / weights.length).round(2)
    }
  end

  def files_report(files_glob)
    Dir[files_glob].map {|path| complexity_report(path) }
  end

end
