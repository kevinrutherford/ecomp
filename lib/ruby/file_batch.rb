require_relative 'javascript_source_batch'

class FileBatch
  def initialize(files, repo)
    @batchresults = {}
    @files = files.map { |path| FileRevision.new(path, repo, @batchresults) }
  end

  def generate_reports
    process_batch
    @files.map(&:complexity_report)
  end

  private
  def process_batch
    jsfilenames = @files.select { |file| file.path =~ /.js$/ }.map { |file| file.path }
    jsresult = process_javascript(jsfilenames)
    # javaresult = ...
    # rubyresult = ...
    # objcresult = ...

    @batchresults.merge!(jsresult)
    # @batchresults.merge!(javaresult)
    # @batchresults.merge!(rubyresult)
    # @batchresults.merge!(objcresult)
  end

  def process_javascript(files)
    batch = JavaScriptSourceBatch.new(files)
    batch.process
  end
end
