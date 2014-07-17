require 'ruby_parser'

class RubySourceFile
  def initialize(path)
    @path = path
    @source_code = IO.readlines(path).join
  end

  def complexity
    ast = RubyParser.for_current_ruby.parse(@source_code)
    @methods = []
    @num_dependencies = 0
    process_ast(ast)
    {
      filename: @path,
      functions: @methods,
      num_dependencies: @num_dependencies
    }
  end

  private

  def process_ast(node)
    return 0 unless has_children?(node)
    if is_method?(node)
      my = 1 + process_children(node)
      @methods << {
        name: node[1],
        complexity: my
      }
      my
    else
      @num_dependencies = @num_dependencies + 1 if is_require?(node)
      comp = process_children(node)
      comp = comp + 1 if is_branch_point?(node)
      comp
    end
  end

  def has_children?(node)
    node.is_a?(Array) && node[0] != :lit
  end

  def is_branch_point?(node)
    complex_nodes.include?(node[0])
  end

  def is_method?(node)
    [:defn, :defs].include?(node[0])
  end

  def is_require?(node)
    node[0] == :call && node[2] == :require
  end

  def process_children(node)
    return 0 unless node && node.size > 1
    node[1..-1].select {|n| n }.map {|n| process_ast(n) }.inject(:+)
  end

  def complex_nodes
    [
      :defn, :defs,
      :if, :case, :when,
      :and, :or,
      :for, :while, :until,
      :rescue, :ensure,
      :iter
    ]
  end
end
