module Lex

  class Token
    def initialize(type,meta="")
      @type=type
      @meta=meta
    end
    
    def type
      @type
    end
    
    def type?
      false
    end

    def meta
      @meta
    end

    def ==(obj)
      @type==obj.type&&@meta==obj.meta
    end
    
    def children
      nil
    end

    def print(indent)
      str = ""
      (0..indent).each do
        str << "\t"
      end
      str << type + ";" + meta
      puts str
    end
  end

  class Stream
    def initialize(str)
      @str=str
      @index=-1
    end

    def nxt
      @index+=1
      @str[@index]
    end

    def peek
      @str[@index+1]
    end

    def rewind
      @index-=1
    end
  end

  class Lexer
    def initialize(stream)
      @stream=stream
    end

    def nxt
      curr = @stream.nxt
      if /\s/ =~ curr then nxt()
      elsif /[a-zA-Z_\-+\/*^=]/ =~ curr then id(curr)
      elsif /[0-9]/ =~ curr then num(curr)
      elsif /[(]/ =~ curr then Token.new("LP")
      elsif /[)]/ =~ curr then Token.new("RP")
      elsif /[\']/ =~ curr then Token.new("COMMA")
      elsif /[;]/ =~ curr
        while(curr!="\n"&&curr!="\r\n")
          curr=@stream.nxt
        end
        nxt
      else
        puts "Unknown character #{curr}"
        exit
      end
    end

    def id c
      curr = @stream.nxt
      if /[a-zA-Z0-9_\-+\/*^=]/ =~ curr then id(c+curr)
      else
        @stream.rewind
        Token.new("ID",c)
      end
    end

    def num c
      curr = @stream.nxt
      if /[0-9]/ =~ curr then num c+curr
      else
        @stream.rewind
        Token.new("NUM",c)
      end
    end

  end
end
