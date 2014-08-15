require 'json'

class JavaSourceFile

  BIN = File.dirname(File.expand_path(__FILE__)) + '/../../bin'

  def initialize(path)
    @path = path
  end

  def complexity
    begin
      json = JSON.parse(`#{BIN}/javancss #{@path}`)
      result = {}
      json.each {|k,v| result[k.to_sym] = v }
      result
    rescue
      puts ">>> bad file "+@path
    end
  end

end
