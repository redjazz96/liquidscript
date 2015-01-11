RSpec::Matchers.define :compile do
  include Liquidscript

  chain :and_produce do |prod|
    @prod = prod
  end

  match do |data|
    if @prod
      (@_out = compiler(data).compile) == @prod
    else
      @_out = compiler(data).compile?
    end
  end

  failure_message do |data|
    "expected #{data} to compile correctly\nexpected: #{expected}\n     got: #{actual}"
  end

  failure_message_when_negated do |data|
    "expected #{data} not to compile (compiled anyway, got: #{@_out})"
  end

  description do |data|
    "compile #{data}"
  end

  diffable

  def expected
    @prod || true
  end

  def actual
    if @_out.respond_to?(:to_a!)
      @_out.to_a!
    else
      @_out
    end
  end

  def compiler(data)
    Compiler::Parser.new(Scanner::Liquidscript.new(data))
  end
end
