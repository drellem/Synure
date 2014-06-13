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
            elsif @children[0].meta=="if"
              return if_
            elsif @children[0].meta=="quote"
              return quote
            end
            @children.each do |c|
              children << Element.new(c,@context).eval
            end
            if(children.length==1)
              return children[0]
            end
            if children[0].type!="FUNC"
              puts "Function expected, but #{children[0].type} node found"
              exit
            end
            fn = children[0]
            (1..children.length-1).each do |i|
              fn = fn.call children[i]
            end
            @value = fn
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
      if @children.length<3
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
        if c[@children[i].nodes[0].meta]!=nil
          puts "Cannot redefine constant #{@children[i].nodes[0].meta} in let expression"
          exit
        end
        #c[@children[i].nodes[0].meta] = nil
        c[@children[i].nodes[0].meta] = Element.new(@children[i].nodes[1],c).eval
      end
      #(1..@children.length-2).each do |i|
       # c[@children[i].nodes[0].meta] = Element.new(@children[i].nodes[1],c).eval
      #end
      Element.new(@children[@children.length-1],c).eval
    end

    def if_
      if @children.length!=4
        puts "'If' function takes three arguments, but found #{@children.length-1} arguments"
        exit
      end
      result = Element.new(@children[1],@context).eval
      if result.type!="BOOL"
        puts "'If' function expects first argument of type 'BOOL' but found argument of type #{result.type}"
        exit
      end
      if result.meta=="true" then return Element.new(@children[2],@context).eval end
      return Element.new(@children[3],@context).eval
    end

    def quote
      if @children.length!=2
        puts "Quote function expects one argument, but found #{@children.length-1} arguments."
        exit
      end
      @children[1]
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
      @@context['true'] = Type.new("BOOL","true")
      @@context['false'] = Type.new("BOOL","false")
      @@context['='] = Func.new {|a| Func.new do |b|
          if (a.type=="NUM"&&b.type=="NUM")||(a.type=="BOOL"&&b.type=="BOOL")
            if a.meta==b.meta then @@context['true'] else @@context['false'] end
          end
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
