require 'ruby_parser'

class RubySourceFile
  def initialize(path)
    @path = path
    @source_code = IO.readlines(path).join
  end

  def complexity
    ast = RubyParser.for_current_ruby.parse(@source_code)
    @num_branches = 0
    @num_dependencies = 0
    process_ast(ast)
    {
      filename: @path,
      num_branches: @num_branches,
      num_dependencies: @num_dependencies
    }
  end

  private

  def process_ast(node)
    return unless node
    @num_dependencies = @num_dependencies + 1 if is_require?(node)
    @num_branches = @num_branches + 1 if is_branch_point?(node)
    return unless has_children?(node)
    node[1..-1].select {|n| n }.each {|n| process_ast(n) }
  end

  def has_children?(node)
    node && node.is_a?(Array) && node[0] != :lit
  end

  def is_branch_point?(node)
    Array === node && branch_nodes.include?(node[0])
  end

  def is_require?(node)
    Array === node && node[0] == :call &&
      [:require, :require_relative].include?(node[2])
  end

  def branch_nodes
    [
      :if, :when,
      :and, :or,
      :for, :while, :until,
      :rescue, :ensure
    ]
  end
end
