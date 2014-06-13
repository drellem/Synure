$LOAD_PATH << '.' 
require 'Lex'
require 'Parse'
require 'Eval'

stream = Lex::Stream.new <<-eos
(let (fac (lambda n
  (if (= n 0) 1 (* n (fac (- n 1))))))
  (fac 3))
eos
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
i.nxt.print

stream = Lex::Stream.new <<-eos
(let (^ (fn (a b)
  (if (= b 1)
      a
      (* a (^ a (- b 1))))))
     (exp (^ 2))
     (exp 3))
eos
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
i.nxt.print
