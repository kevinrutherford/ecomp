class ReportFolder

  def initialize(folder)
    @folder = folder
  end

  def update(key, report_doc)
    ensure_output_folder_exists
    File.open("#{@folder}/#{key}.json", 'w') {|f| f.puts JSON.pretty_generate(report_doc.raw_data) }
  end

  private

  def ensure_output_folder_exists
    `mkdir -p #{@folder}`
  end

end
