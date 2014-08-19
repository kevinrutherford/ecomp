class JavaSourceBatch

  BIN = File.dirname(File.expand_path(__FILE__)) + '/../../bin'

  def initialize(paths)
    @paths = paths
  end

  def process
    results = {}
    if (@paths.length > 0)
      paths_as_list = @paths.join(' ')
      json = JSON.parse(`#{BIN}/javancss #{paths_as_list}`)
      json.each { |path, item|
        results[path] = process_item(item)
      }
    end
    results
  end

  private
  def process_item(item)
    result = {}
    if !item.nil?
      item.each { |k, v| result[k.to_sym] = v }
    end
    result
  end
end