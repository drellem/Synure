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
raise "Parser fail 1" unless a.nodes[0].nodes[2].nodes[1].nodes[1].meta=="f"
#a.print

#Problem here
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

stream = Lex::Stream.new <<-eos
'(im a happy camper lol)
eos
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
raise "Quote fail 1" unless i.nxt.type=="LIST"

stream = Lex::Stream.new <<-eos
(list 2 3 'b)
eos
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
raise "List fail 1" unless i.nxt.type=="LIST"

stream = Lex::Stream.new <<-eos
((fn (a b) (+ a b)) 2 3)
eos

lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
raise "Fn fail 1" unless i.nxt.meta==5

stream = Lex::Stream.new <<-eos
(define a 5)
a
eos
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
raise "Define fail 1" unless i.nxt.meta==5

stream = Lex::Stream.new <<-eos
(defn fac (n)
  (if (= n 0)
      1
      (* n (fac (- n 1)))))
(- (fac 3) 1)
eos
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
raise "Defn fail 1" unless i.nxt.meta==5

stream = Lex::Stream.new <<-eos
(if (and true false) 3 2)
eos
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
raise "And fail 1" unless i.nxt.meta==2

stream = Lex::Stream.new <<-eos
(defmacro or (a b) '(if a true b))
(or true false)
eos
lexer = Lex::Lexer.new(stream)
parser = Parse::Parser.new(lexer)
i = Eval::Interpreter.new(parser)
raise "Defmacro fail 1" unless i.nxt.meta=='true'

puts "Test complete"
