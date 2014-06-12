$LOAD_PATH << '.' 
require 'Lex'
require 'Parse'
require 'Eval'

stream = Lex::Stream.new("abc")
raise "Stream fail" unless stream.peek=="a"
raise "Stream fail" unless stream.nxt=="a"
raise "Stream fail" unless stream.nxt=="b"
raise "Stream fail" unless stream.peek=="c"

stream = Lex::Stream.new("a bc 123()")
lexer = Lex::Lexer.new(stream)
raise "Lexer fail 1" unless lexer.nxt==Lex::Token.new("ID","a")
raise "Lexer fail 2" unless lexer.nxt==Lex::Token.new("ID","bc")
raise "Lexer fail 3" unless lexer.nxt==Lex::Token.new("NUM","123")
raise "Lexer fail 4" unless lexer.nxt==Lex::Token.new("LP")
raise "Lexer fail 5" unless lexer.nxt==Lex::Token.new("RP")

stream = Lex::Stream.new("(a (b c) (d (e f)) 13)")
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
a,d = parser.nxt
a.print

stream = Lex::Stream.new("((lambda a (lambda b (+ a b))) 1 2)")
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
raise "Lambda fail 1" unless i.nxt.meta==3

stream = Lex::Stream.new <<-eos
(let (x 1)
  (y (+ x 1))
  (+ x y))
eos
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
raise "Let fail 1" unless i.nxt.meta==3

stream = Lex::Stream.new <<-eos
(if (= 1 2) 2 3)
eos
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
raise "If fail 1" unless i.nxt.meta==3

puts "Test complete"
