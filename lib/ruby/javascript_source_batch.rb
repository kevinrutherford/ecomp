class JavaScriptSourceBatch

  BIN = File.dirname(File.expand_path(__FILE__)) + '/../../bin'

  def initialize(paths)
    @paths = paths
  end

  def process
    paths_as_list = @paths.join(' ')
    json = JSON.parse(`node #{BIN}/../lib/js/js_parser.js #{paths_as_list}`)
    results = {}
    json.each { |path, item|
      results[path] = process_item(item)
    }
    results
  end

  private
  def process_item(item)
    result = {}
    item.each { |k, v| result[k.to_sym] = v }
    result
  end
end