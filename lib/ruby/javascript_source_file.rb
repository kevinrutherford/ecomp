require 'json'

class JavascriptSourceFile

  BIN = File.dirname(File.expand_path(__FILE__)) + '/../../bin'

  def initialize(path)
    @path = path
  end

  def complexity
    json = JSON.parse(`node #{BIN}/../lib/js/js_parser.js #{@path}`, :symbolize_names => true)
    begin
      json.first[1]
    rescue
      puts "WARN: Failed to parse JavaScript file: #{@path}"
    end
  end

end
