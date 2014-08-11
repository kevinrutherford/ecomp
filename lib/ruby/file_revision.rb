require_relative 'ruby_source_file'
require_relative 'java_source_file'
require_relative 'javascript_source_file'

class FileRevision

  def initialize(path, repo)
    @path = path
    @repo = repo
  end

  def complexity_report
    report = case @path
             when /.*\.rb$/
               RubySourceFile.new(@path).complexity
             when /.*\.java$/
               JavaSourceFile.new(@path).complexity
             when /.*\.js$/
               JavascriptSourceFile.new(@path).complexity
             end
    e = 1 + report[:num_dependencies]
    b = 1 + report[:num_branches]
    s = 1 + report[:num_superclasses]
    report['weight'] = b * e * s
    report[:churn] = @repo.num_commits_involving(@path)
    report[:filename] = @path
    report
  end

end
