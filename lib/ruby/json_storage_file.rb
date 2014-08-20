class JSONStorageFile

  def initialize(filepath)
    @filepath = filepath

    if not file_exists
      puts "JSONStorageFile: No file found with path '#{@filepath}'"
      @content = Array.new
    else
      File.open(@filepath, "r") do |f|
        @content = JSON.load(f)
      end
    end

  end

  def get_content
    return @content
  end

  def set_content(content)
    @content = content
  end

  def write_file
    File.open(@filepath, 'w') {|f| f.puts JSON.pretty_generate(@content) }
    initialize(@filepath)
  end

  private

  def file_exists
    File.file?(@filepath)
  end

end
