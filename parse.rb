$LOAD_PATH << '.' 
require 'Lex'

module Parse

  class AST
    def initialize(token,nodes=[])
      @token=token
      @nodes=nodes
    end
    
    def type
      @token.type
    end

    def type?
      false
    end

    def meta
      @token.meta
    end

    def addChild(node)
      @nodes << node
    end

    def ==(obj)
      return false unless (type==obj.type) && (meta==obj.meta)
      @nodes.each do |n|
        obj.each do |o|
          return false unless n==o
        end
      end
      true
    end

    def to_s
      if @nodes==[]
        meta
      else
        s = "( "
        @nodes.each do |n|
          s << n.to_s << " "
        end
        s << ")"
      end
    end

    def nodes
      @nodes
    end

    def print
      puts to_s
    end
  end

  class Parser
    def initialize(stream)
      @stream=stream
      @ast = AST.new(Lex::Token.new("MAIN"))
    end

    def nxt(ast=@ast)
      curr = @stream.nxt
      done = false
      if curr.type == "NUM" then ast.addChild(AST.new(curr))
      elsif curr.type == "ID" then ast.addChild(AST.new(curr))
      elsif curr.type == "COMMA"
        a = AST.new(Lex::Token.new("LIST"))
        a.addChild(Lex::Token.new("ID","quote"))
        a,d = nxt a
        ast.addChild a
      elsif curr.type == "LP"
        a = AST.new(Lex::Token.new("LIST"))
        d = false
        while !d
          a,d = nxt a
        end
        ast.addChild a
      elsif curr.type == "RP"
        done = true
      else
        puts "Unknown token #{curr.type}"
        exit
      end
      return ast, done
    end
  end
end
