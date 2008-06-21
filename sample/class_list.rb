
require "rubygems"
require "javaclass"
require "zip/zip"

# ZipInputStreamにはgetcが実装されていないので、追加する。
module Zip
  class ZipInputStream
    def getc
      read(1)[0]
    end
  end
end

# Zipエントリ内のクラス一覧を列挙して解析する。
def each_class ( zip_file, &block ) 
  Zip::ZipFile.foreach(ARGV[0]) {|entry|
    next unless entry.file?
    next unless entry.name =~ /.*\.class$/
    entry.get_input_stream {|io|
      jc = JavaClass.from io
      block.call( jc ) if block_given?
    }
  }
end

class TypeHierarchy
  def initialize
    @classes = {}
  end
  def add( jc )
    (jc.interfaces << jc.super_class).each {
      if ( super_class != "java.lang.Object" )
      @classes[super_class] = Type.new unless @classes.key? super_class
      
      end
    }
    
  end
  def to_s
    
  end
end

class Type
  def initialize( java_class=nil  )
    @implementors = []
    @java_class = java_class
  end
  attr :java_class, true
  attr :implementors, true
end
