require_relative 'json_storage_file'
require 'json'

# TODO migrate recording of hot spots and developer behaviour reports to here?
class MetricsDAO

  def initialize(folder)
    @folder = folder
    @commits = JSONStorageFile.new("#{@folder}/commits.json")
  end

  def get_all_revision_metrics
    @commits.get_content
  end

  def get_latest_revision_metrics
    @commits.get_content.last
  end

  def add_revision_summary(revision_summary)
    @commits.get_content << revision_summary.raw_data
    @commits.write_file
  end

end