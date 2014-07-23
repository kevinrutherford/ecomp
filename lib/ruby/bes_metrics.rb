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
    @repo = LocalGitRepo.new
    @repo.reset
    prepare_output_folder(@outdir)
    write_json_file("#{@outdir}/current_files.json", files_report(@glob))
    commits = all_commits
    update_with_complexity(commits, @glob)
    write_json_file("#{@outdir}/commits.json", commits)
    recent = select_recent_commits(commits)
    write_json_file("#{@outdir}/recent_commits_by_author.json", recent)
    @repo.reset
    $stderr.puts ''
  end

  def churn(path)
    `git log --pretty=%h #{path} | wc -l`.to_i
  end

  def all_commits
    raw_log = `git log --pretty="%h/%aN/%ci/%s" --shortstat`
    lines = raw_log.split("\n")
    result = []
    (0..(lines.length-1)).each do |i|
      if lines[i].empty?
        fields = lines[i-1].split('/')
        count = lines[i+1].to_i
        result << {
          ref: fields[0],
          author: fields[1],
          date: fields[2],
          comment: fields[3..-1].join,
          num_files_touched: count
        }
      end
    end
    result.reverse
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
    report[:churn] = churn(path)
    report
  end

  def update_with_complexity(commits, files_glob)
    commits.each do |commit|
      @repo.checkout(commit[:ref])
      $stderr.print '.'
      files = Dir[files_glob]
      file_reports = files.map {|path| complexity_report(path) }
      if file_reports.empty?
        commit[:complexity] = {
          sum_of_file_weights: 0,
          max_of_file_weights: 0,
          mean_of_file_weights: 0.0
        }
      else
        weights = file_reports.map {|rpt| rpt['weight'] }
        weight_sum = weights.inject(:+)
        commit[:complexity] = {
          sum_of_file_weights: weight_sum,
          max_of_file_weights: weights.max,
          mean_of_file_weights: (weight_sum.to_f / weights.length).round(2)
        }
      end
    end
  end

  def group_by_author(commits)
    commits.group_by {|commit| commit[:author] }.map do |author, commits|
      { author: author, commits: commits }
    end
  end

  def select_recent_commits(commits)
    cutoff = DateTime.now - DELTA_CUTOFF_DAYS
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
    File.open(path, 'w') {|f| f.puts JSON.pretty_generate(data) }
  end

end
