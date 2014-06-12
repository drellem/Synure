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

    def type?
      false
    end

    def eval
          if @ast.type? then @value = @ast
          elsif(@type=="NUM") then @value=Type.new("NUM",@ast.meta.to_f)
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
            if @children[0].meta=="lambda"
              return lambda
            elsif @children[0].meta=="let"
              return let
            end
            @children.each do |c|
              children << Element.new(c,@context).eval
            end
            if children[0].type!="FUNC"
              puts "Function expected, but #{children[0].type} node found"
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

    def lambda
      if @children.length!=3
        puts "Lambda function expects two arguments"
        exit
      end
      if @children[1].type!="ID"
        puts "Lambda function first arguments expects ID but found #{@children[1].type}"
        exit
      end
      Lambda.new(@children[1].meta,@children[2],@context)
    end

    def let
      if @children.length<2
        puts "Let function expects at least two arguments."
        exit
      end
      c = @context
      (1..@children.length-2).each do |i|
        if @children[i].type!="LIST"
          puts "Let function initial arguments expects LIST but found #{@children[i].type}"
          exit
        end
        if @children[i].nodes.length!=2
          puts "Let function initial arguments expects LISTs of length 2 but found LIST of length #{@children[i].nodes.length}"
          exit
        end
        if @children[i].nodes[0].type!="ID"
          puts "Let function initial arguments expects ID,expr but found #{@children[i].nodes[0].type},expr with value #{@children[i].nodes[0].meta}"
          exit
        end
        c[@children[i].nodes[0].meta] = nil
      end
      (1..@children.length-2).each do |i|
        c[@children[i].nodes[0].meta] = Element.new(@children[i].nodes[1],c).eval
      end
      Element.new(@children[@children.length-1],c).eval
    end

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

    def type?
      true
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

  class Lambda < Func
    def initialize(id,ast,context)
      @id = id
      @ast = ast
      @context=context
      @type="FUNC"
    end

    def call a
      c = @context
      c[@id] = a
      Element.new(@ast,c).eval
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
