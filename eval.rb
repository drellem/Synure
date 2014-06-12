$LOAD_PATH << '.' 
require 'Parse'

module Eval
  
  class Element
    def initialize(ast, context)
      @ast=ast
      @type = ast.type
      @children = ast.nodes
      @context=context
    end

    def eval
          if(@type=="NUM") then @value=Type.new("NUM",@ast.meta.to_f)
          elsif @type=="ID"
            val=@context[@ast.meta]
            if val==nil
              puts "Object #{@ast.meta} not defined"
              exit
            end
            @value=val
          elsif @type=="LIST"
            if(@children==nil)
              puts "\"()\" form invalid"
              exit
            end
            children=[]
            @children.each do |c|
              children << Element.new(c,@context).eval
            end
            if children[0].type!="FUNC"
              puts "Function expected, but #{@children[0].type} node found"
              exit
            end
            if(children.length==1)
              @value=children[0].call
            else
              fn = children[0]
              (1..children.length-1).each do |i|
                fn = fn.call children[i]
              end
              @value = fn
            end
          elsif @type=="MAIN"
            c = nil
            @children.each do |ch|
              c = Element.new(ch,@context).eval
            end
            @value=c
          end
          @value
    end #end fn
  end #end class

  class Type
    def initialize(type,meta)
      @type=type
      @meta=meta
    end

    def type
      @type
    end

    def meta
      @meta
    end

    def print
      puts @meta
    end
  end

  class Func < Type
    def initialize(&fn)
      @type="FUNC"
      @meta=""
      @fn=fn
    end

    def call a 
      @fn.call a
    end

    def print
      puts "FUNC"
    end
  end

  class DefaultContext
    def self.init
      @@context=Hash.new
      @@context['+'] = Func.new {|a| Func.new do |b|
          if a.type!="NUM" || b.type!="NUM"
            puts "Cannot perform function '+' with types #{a.type} and #{b.type}"
            exit
          end
          Type.new("NUM",a.meta+b.meta)
      end
      }
          
      @@context['-'] = Func.new {|a|  Func.new do |b|
            if a.type!="NUM" || b.type != "NUM"
              puts "Cannot perform function '-' with types #{a.type} and #{b.type}"
              exit
            end
            Type.new("NUM", a.meta-b.meta)
      end
      }

      @@context['*'] = Func.new {|a| Func.new do |b|
          if a.type != "NUM" || b.type != "NUM"
            puts "Cannot perform function '*' with types #{a.type} and #{b.type}"
            exit
          end
          Type.new("NUM",a.meta*b.meta)
      end
      }

      @@context['/'] = Func.new {|a| Func.new do |b|
          if a.type != "NUM" || b.type != "NUM"
            puts "Cannot perform function '/' with types #{a.type} and #{b.type}"
            exit
          end
          Type.new("NUM",a.meta/b.meta)
      end
      }
    end

    def self.context
      @@context
    end
  end #end class

  class Interpreter
    def initialize(parser)
      @parser = parser
      DefaultContext.init
    end

    def nxt
      a,d = @parser.nxt
      e = Element.new(a,DefaultContext.context).eval
      return e
    end
  end
end
