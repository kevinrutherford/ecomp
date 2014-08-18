require_relative 'javascript_source_batch'
require_relative 'java_source_batch'

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
    if not jsfilenames.empty?
      jsresult = process_javascript(jsfilenames)
      @batchresults.merge!(jsresult)
    end
    
    javafilenames = @files.select { |file| file.path =~ /.java$/ }.map { |file| file.path }
    if not javafilenames.empty?
      javaresult = process_java(javafilenames)
      @batchresults.merge!(javaresult)
    end
    # rubyresult = ...
    # objcresult = ...
    
    # @batchresults.merge!(rubyresult)
    # @batchresults.merge!(objcresult)
  end

  def process_javascript(files)
    batch = JavaScriptSourceBatch.new(files)
    batch.process
  end
  
  def process_java(files)
    batch = JavaSourceBatch.new(files)
    batch.process
  end
end
