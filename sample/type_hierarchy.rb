#!/usr/bin/ruby

# jar内のクラスファイルの型階層を表示する。
#
# ./type_hierarchy.rb <jarファイル>
#

require "rubygems"
require "javaclass"
require "zip/zip"
require "kconv"

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

# 型階層
class TypeHierarchy
  def initialize
    @classes = {}
  end
  def <<( jc )
    (jc.interfaces << jc.super_class).each {|parent|
      next if parent == nil || parent == "java.lang.Object"
      @classes[parent] = Type.new(parent) unless @classes.key? parent
      @classes[parent] << jc.name
    }
    name = jc.name
    @classes[name] = Type.new(name) unless @classes.key? name
    @classes[name].java_class = jc
  end
  def to_s
    strs = ""
    @classes.each{|k,v|
      jc = v.java_class
      next if jc != nil && jc.super_class != nil && jc.super_class != "java.lang.Object"
      next if jc != nil && jc.interfaces.length > 0
      strs << "---\n" <<  v.node_to_string( "", @classes ) << "\n"
    }
    return strs
  end
end

# 型
class Type
  def initialize( name, java_class=nil  )
    @name = name
    @implementors = []
    @java_class = java_class
  end
  def <<(implementor)
    @implementors << implementor
  end
  def node_to_string( indent, pool )
    str = indent.dup
    str << ( java_class == nil ? "(unknown) " : java_class.access_flag.type + " " ) 
    str << name
    str << "\n"
    child_indent = indent.gsub(/├/, "│").gsub(/└/, "　")
    @implementors.each_index {|i|
       next if implementors[i] == nil
       tmp = child_indent + ( i >= implementors.length-1 ? "└" : "├" )
       str <<  pool[implementors[i]].node_to_string( tmp, pool )
    }
    return str
  end
  attr :name, true
  attr :java_class, true
  attr :implementors, true
end

th = TypeHierarchy.new
each_class( ARGV[0] ){|jc|
  th << jc
}
puts th.to_s.tosjis
