require 'date'
require 'json'
require_relative 'ruby_source_file'
require_relative 'local_git_repo'

class BesMetrics

  BIN = File.dirname(File.expand_path(__FILE__)) + '/../../bin'
  DELTA_CUTOFF_DAYS = 365

  def initialize(outdir: '.', glob: '*/**/*.*')
    @outdir = outdir
    @glob = glob
  end

  def collect
    prepare_output_folder(@outdir)
    write_json_file("current_files.json", files_report(@glob))
    commits = repo.all_commits
    update_with_complexity(commits)
    write_json_file("commits.json", commits)
    recent = select_recent_commits(commits)
    write_json_file("recent_commits_by_author.json", recent)
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

  def java_report(path)
    json = JSON.parse(`#{BIN}/javancss #{path}`)
    result = {}
    json.each {|k,v| result[k.to_sym] = v }
    result
  end

  def complexity_report(path)
    report = case path
             when /.*\.rb$/
               RubySourceFile.new(path).complexity
             when /.*\.java$/
               java_report(path)
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

  def group_by_author(commits)
    commits.group_by {|commit| commit[:author] }.map do |author, commits|
      { author: author, commits: commits }
    end
  end

  def select_recent_commits(commits)
    cutoff = DateTime.parse(commits[-1][:date]) - DELTA_CUTOFF_DAYS
    recent = commits.select {|c| DateTime.parse(c[:date]) > cutoff }
    recent.each_with_index do |commit, i|
      delta = commit[:complexity][:sum_of_file_weights] - (i > 0 ? recent[i-1][:complexity][:sum_of_file_weights] : 0)
      commit[:complexity][:delta_sum_of_file_weights] = delta
    end
    group_by_author(recent[1..-1])
  end

  def files_report(files_glob)
    Dir[files_glob].map {|path| complexity_report(path) }
  end

  def prepare_output_folder(folder)
    `mkdir -p #{folder}`
  end

  def write_json_file(path, data)
    File.open("#{@outdir}/#{path}", 'w') {|f| f.puts JSON.pretty_generate(data) }
  end

end
