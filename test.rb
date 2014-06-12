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

stream = Lex::Stream.new("(* 2 (+ 2 (- 10 5)))")
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
i.nxt.print

puts "Test complete"
