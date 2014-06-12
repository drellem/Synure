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

    def print(indent=0)
      str = ""
      (0..indent).each do
        str << "\t"
      end
      str << type + ";" + meta
      puts str
      @nodes.each do |n|
        n.print indent+1
      end
    end
    def nodes
      @nodes
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
