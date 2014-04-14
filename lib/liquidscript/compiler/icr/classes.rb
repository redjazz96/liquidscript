module Liquidscript
  module Compiler
    class ICR
      module Classes

        def compile_class
          shift :class
          name = shift :identifier
          inherit = nil
          set name
          # Inheritance ftw!
          if peek?(:colon)
            shift :colon
            inherit = shift :identifier
            inherit = ref(inherit)
          end


          new_context = Liquidscript::ICR::Context.new
          new_context.parents << top.context
          new_context.class!
          @classes[name.value] = new_context

          top.context = new_context
          body = _compile_class_body(false)

          new_context.undefined.each do |f|
            raise f[1]
          end

          code :class, name, inherit, body, top.contexts.pop
        end

        def compile_module
          m = shift :module
          if peek? :identifier
            name = shift :identifier
            set name
            body = _compile_class_body(true)

            code :module, name, body
          else
            value_expect _new_token(m, :identifier)
          end
        end

        def _new_token(old, type)
          Scanner::Token.new(type, old.type.to_s, old.line,
                             old.column)
        end

        def _compile_class_body(mod = false)
          shift :lbrace

          components = []

          compile_object = action do
            components << [
              _compile_class_body_key(mod),
              compile_vexpression
            ]
          end

          loop do
            expect :newline, :rbrace => action.end_loop,
            :comma         => action.shift,
            :module        => action { components << compile_module },
            :class         => action { components << compile_class  },
            [:identifier, :istring] => compile_object
          end

          components
        end

        def _compile_class_body_key(mod)
          item = shift :identifier, :istring

          item = compile_property(item) if item.type == :identifier &&
            peek?(:prop) && !mod

          if item.type == :identifier && !mod
            set(item)
          end

          shift :colon
          item
        end
      end
    end
  end
end
