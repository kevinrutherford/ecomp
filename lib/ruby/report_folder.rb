class ReportFolder

  def initialize(folder)
    @folder = folder
  end

  def update(key, report_doc)
    ensure_output_folder_exists

    filename = "#{@folder}/#{key}.json"

    existingJson = JSON.parse(File.open(filename).read)
    report_doc.raw_data.each do |data|
      existingJson << data
    end

    File.open(filename, 'w') {|f| f.puts JSON.pretty_generate(existingJson) }
  end

  private

  def ensure_output_folder_exists
    `mkdir -p #{@folder}`
  end

end
