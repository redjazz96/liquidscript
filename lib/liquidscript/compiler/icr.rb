require "liquidscript/compiler/icr/expressions"
require "liquidscript/compiler/icr/functions"
require "liquidscript/compiler/icr/literals"
require "liquidscript/compiler/icr/classes"
require "liquidscript/compiler/icr/helpers"

module Liquidscript
  module Compiler
    class ICR < Base

      include Expressions
      include Functions
      include Literals
      include Classes
      include Helpers

      # (see Base#reset!)
      def reset!
        @top         = Liquidscript::ICR::Set.new
        @top.context = Liquidscript::ICR::Context.new
        @set         = [@top]
        super
      end

      # (see Base#top)
      def top
        @set.last
      end

      # Sets the starting point for compiliation.
      #
      # @return [ICR::Code]
      def compile_start
        compile_expression
      end
    end
  end
end
