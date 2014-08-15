require 'json'

class MetricsDAO

  def initialize(folder)
    @folder = folder
  end

  def get_all_commits
    if not file_exists('commits')
      return
    end
    commits = load_json_file('commits')
    if (commits.size < 1)
      return
    end
    revision_numbers = Array.new
    commits.each { |commit| revision_numbers.push(commit['ref']) }
    revision_numbers
  end

  def add_commit(revision_summary)

  end

  def last_commit
    all_commits = get_all_commits
    if not all_commits.nil?
      get_all_commits.last
    end
  end

  # TODO add_file

  private

  def file_exists(filename)
    File.file?(full_path(filename))
  end

  def full_path(filename)
    "#{@folder}/#{filename}.json"
  end

  def load_json_file(filename)
    File.open(full_path(filename), "r") do |f|
      return JSON.load(f)
    end
  end

end