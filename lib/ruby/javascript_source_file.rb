require 'json'

class JavascriptSourceFile

  BIN = File.dirname(File.expand_path(__FILE__)) + '/../../bin'

  def initialize(path)
    @path = path
  end

  def complexity
    #puts(@path)
    json = JSON.parse(`node #{BIN}/../lib/js/js_parser.js #{@path}`)
    #puts(json)
    result = {}
    json.each {|k,v| result[k.to_sym] = v }
    result
  end

end
