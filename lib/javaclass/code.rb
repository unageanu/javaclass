

module JavaClass
  
  # コード
  class Code
    include JavaClass::Base
    def initialize( java_class, index, opcode, operands=[], wide=false )
      @java_class = java_class
      @index = index
      @opcode = opcode
      @operands = operands
      @wide = wide
    end
    def to_s
#      opts = values = operands.inject(""){|str,i|
#        if i.name == "index"
#          c = @java_class.get_constant(i.value)
#          str += c.kind_of?(MemberRefConstant) ? c.name_and_type.name : c.to_s 
#        end
#        str
#      }
      values = operands.map{|i|i.to_s}
      values.unshift( Converters.convert_code(opcode) )
      values.unshift( "#{@index} :" )
#      values.push( "#" + opts ) if !opts.empty?
      return values.join(" ") 
    end
    def to_bytes
      bytes = []
      bytes += to_byte( 0xC4, 1 ) if wide
      bytes += to_byte( opcode, 1 )
      operands.each {|o|
        bytes += o.to_bytes
      }
      return bytes
    end
    # JavaClass
    attr :java_class, true
    # インデックス
    attr :index, true
    # opcode
    attr :opcode, true
    # operands
    attr :operands, true
    # wideかどうか
    attr :wide, true
  end
  
  # オペランド
  class Operand
    include JavaClass::Base
    def initialize( size, value, name="" )
      @size = size
      @value = value
      @name=name
    end
    def to_s
      value.to_s
    end
    def to_bytes
      bytes = []
      if size =~ /(u|s)(\d)/
        bytes += to_byte( value, $2.to_i, $1=="s" )
      else
        raise "unknown size. size=#{size}"
      end
      return bytes
    end
    # データサイズ( s1, u1 ..etc.. )
    attr :size, true
    # 値
    attr :value, true
    # 表示名
    attr :name, true
  end
  
end