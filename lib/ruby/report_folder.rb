class ReportFolder

  def initialize(folder)
    @folder = folder
  end

  def update(key, report_doc)
    prepare_output_folder
    File.open("#{@folder}/#{key}.json", 'w') {|f| f.puts JSON.pretty_generate(report_doc.raw_data) }
  end

  private

  def prepare_output_folder
    `mkdir -p #{@folder}`
  end

end
