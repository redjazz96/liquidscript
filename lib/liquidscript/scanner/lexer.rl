%%{

  machine lexer;

  variable data @data;
  variable p    @p;
  variable pe   @pe;
  variable eof  @eof;
  access @;

  number_integer = '-'? [0-9][1-9]*;
  number_frac = '.' [0-9]+;
  number_e = ('e' | 'E') ('+' | '-' | '');
  number_exp = number_e [0-9]+;
  number = number_integer number_frac? number_exp?;

  string_double = '"' ( any -- '"' | '\\"' )* '"';
  identifier = [A-Za-z_$][A-Za-z0-9_$]*;
  string_single = "'" [A-Za-z0-9_$\-]+;


  main := |*
    number        => { emit :number      };
    string_double => { emit :dstring     };
    string_single => { emit :sstring     };
    identifier    => { emit :identifier  };
    '->'          => { emit :arrow       };
    '='           => { emit :equal       };
    '{'           => { emit :lbrack      };
    '('           => { emit :lparen      };
    '['           => { emit :lbrace      };
    '}'           => { emit :rbrack      };
    ')'           => { emit :rparen      };
    ']'           => { emit :rbrace      };
    ':'           => { emit :colon       };
    '.'           => { emit :prop        };
    ','           => { emit :comma       };
    space         => {                   };
    any           => { error             };
  *|;
}%%

module Liquidscript
  class Scanner

    class Lexer

      attr_reader :tokens

      def initialize
        %% write data;
        # %% # fix
        @tokens = []
      end

      def clean!
        @p = nil
        @pe = nil
        @te = nil
        @ts = nil
        @act = nil
        @eof = nil
        @top = nil
        @data = nil
        @stack = nil
      end

      def emit(type)
        @tokens << Token.new(type, @data[@ts..(@te - 1)])
      end

      def error
        raise SyntaxError, "Unexpected #{@data[@ts..(@te-1)].pack('c*')}"
      end

      def perform(data)
        @data = data.unpack("c*") if data.is_a? String
        @eof = data.length

        @tokens = []

        %% write init;
        %% write exec;

        clean!

        @tokens
      end
    end
  end
end
