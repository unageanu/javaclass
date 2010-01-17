#!/usr/bin/ruby

require "rubygems"
require "zip/zip"
require "javaclass"
require "kconv"

# クラスプール
class ClassPool
  def initialize
    @classes = {}
    @classes_r = {}
  end
  def <<( jc )
    jc.methods.each {|m|
      key = jc.name + "#" + m.name + m.descriptor
      @classes[key] ||= []
      next unless m.attributes.key? "Code"
      m.attributes["Code"].codes.each {|code|
        case code.opcode
          when 0xB6,0xB7,0xB8,0xB9
            m = jc.get_constant( code.operands[0].value )
            add_caller( key,
              m.class_name.name + "#" +
              m.name_and_type.name + m.name_and_type.descriptor
            )
          when 0xB2,0xB3,0xB4,0xB5
            m = jc.get_constant( code.operands[0].value )
            add_caller( key,
              m.class_name.name + "." + m.name_and_type.name
            )
        end
      }
    }
  end
  attr_reader :classes
  attr_reader :classes_r
private
  def add_caller( from, to )
    @classes[from] ||= []
    @classes[from] << to
    @classes_r[to] ||= []
    @classes_r[to] << from
  end
end

#ノード
class Node
  def initialize( name  )
    @name = name
    @children = []
  end
  def <<(child)
    @children << child
  end
  def to_s( indent="" )
    str = indent.dup
    str << name.to_s << "\n"
    child_indent = indent.gsub(/├/, "│").gsub(/└/, "　")
    @children.each_index {|i|
       next if children[i] == nil
       tmp = child_indent + ( i >= children.length-1 ? "└" : "├" )
       str << children[i].to_s( tmp )
    }
    return str
  end
  attr :name, true
  attr :children, true
end

#呼び出し元を収集する。
def collect( pool, start, stop=[], node=nil, checked=[] )
  node ||= Node.new(start.to_s)
  return node unless pool.classes_r.key? start
  pool.classes_r[start].each {|caller|
    next if checked.find{|i| i==caller }
    next if stop && stop.find{|i| caller =~ i }
    checked.push start.to_s
    node << collect( pool, caller, stop, Node.new( caller ), checked ) 
    checked.pop
  }
  return node
end

# クラス情報を収集
pool = ClassPool.new
JavaClass::Utils.each_class( *ARGV[0].split(";") ){|jc|
  pool << jc
}
# 呼び出し元をツリー表示
puts collect(pool,  ARGV[1]).to_s

 


