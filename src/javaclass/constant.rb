require "javaclass/util"

module JavaClass

  #
  #=== Constantの基底クラス
  #
	class Constant
    include JavaClass::Util

    CONSTANT_Class = 7
    CONSTANT_Fieldref = 9
    CONSTANT_Methodref = 10
    CONSTANT_InterfaceMethodref = 11
    CONSTANT_String = 8
    CONSTANT_Integer = 3
    CONSTANT_Float = 4
    CONSTANT_Long = 5
    CONSTANT_Double = 6
    CONSTANT_NameAndType = 12
    CONSTANT_Utf8 = 1

    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #
    def initialize( java_class, tag=nil )
      @java_class = java_class
      @tag  = tag
    end

    def to_bytes()
      to_byte( @tag, 1)
    end

    attr :tag, true
    attr :java_class, true
  end

  #
  #=== ClassConstant
  #
  class ClassConstant < Constant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*name_index::名前を示すconstant_poolのインデックス
    #
    def initialize( java_class, tag=nil, name_index=nil )
      super( java_class, tag )
      @name_index = name_index
    end
    #
    #===クラス名を取得する。
    #
    #<b>戻り値</b>::クラス名
    #
    def name
      value = @java_class.get_constant_value(@name_index)
      return value.gsub(/\//, ".")
    end
    def to_bytes()
      super + to_byte( @name_index, 2)
    end
    attr :name_index, true
  end

  #
  #=== フィールド、メソッドのConstantの共通基底クラス
  #
  class MemberRefConstant < Constant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*class_name_index::フィールドorメソッドを持つクラス名を示すconstant_poolのインデックス
    #*name_and_type_index::フィールドorメソッドの名前とディスクリプタを示すconstant_poolのインデックス
    #
    def initialize( java_class, tag=nil, class_name_index=nil, name_and_type_index=nil )
      super(java_class, tag)
      @class_name_index    = class_name_index
      @name_and_type_index = name_and_type_index
    end
    #
    #===フィールドorメソッドを持つクラスのconstantを取得する
    #
    #<b>戻り値</b>::フィールドorメソッドを持つクラスのconstant
    #
    def class_name
      @java_class.get_constant(@class_name_index)
    end
    #
    #===フィールドorメソッドの名前とディスクリプタを示すconstantを取得する
    #
    #<b>戻り値</b>::フィールドorメソッドの名前とディスクリプタを示すconstantを取得する
    #
    def name_and_type
      @java_class.get_constant(@name_and_type_index)
    end
    def to_bytes()
      bytes = super
      bytes += to_byte( @class_name_index, 2 )
      bytes += to_byte( @name_and_type_index, 2 )
    end
    attr :class_name_index, true
    attr :name_and_type_index, true
  end
  #
  #=== フィールドのConstant
  #
  class FieldRefConstant < MemberRefConstant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*class_name_index::フィールドorメソッドを持つクラス名を示すconstant_poolのインデックス
    #*name_and_type_index::フィールドorメソッドの名前とディスクリプタを示すconstant_poolのインデックス
    #
    def initialize( java_class, tag=nil, class_name_index=nil, name_and_type_index=nil )
      super
    end
  end
  #
  #=== メソッドのConstant
  #
  class MethodRefConstant < MemberRefConstant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*class_name_index::フィールドorメソッドを持つクラス名を示すconstant_poolのインデックス
    #*name_and_type_index::フィールドorメソッドの名前とディスクリプタを示すconstant_poolのインデックス
    #
    def initialize( java_class, tag=nil, class_name_index=nil, name_and_type_index=nil )
      super
    end
  end
  #
  #=== インターフェイスメソッドのConstant
  #
  class InterfaceMethodRefConstant < MemberRefConstant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*class_name_index::フィールドorメソッドを持つクラス名を示すconstant_poolのインデックス
    #*name_and_type_index::フィールドorメソッドの名前とディスクリプタを示すconstant_poolのインデックス
    #
    def initialize( java_class, tag=nil, class_name_index=nil, name_and_type_index=nil )
      super
    end
  end

  #
  #=== 名前と型のConstant
  #
  class NameAndTypeConstant < Constant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*name_index::名前を示すconstant_poolのインデックス
    #*descriptor_index::ディスクリプタを示すconstant_poolのインデックス
    #
    def initialize( java_class, tag=nil, name_index=nil, descriptor_index=nil )
      super(java_class, tag)
      @name_index       = name_index
      @descriptor_index = descriptor_index
    end
    #
    #=== 名前を取得する
    #
    #<b>戻り値</b>::名前
    #
    def name
      @java_class.get_constant_value(@name_index)
    end
    #
    #=== ディスクリプタを取得する
    #
    #<b>戻り値</b>::ディスクリプタ
    #
    def descriptor
      @java_class.get_constant_value(@descriptor_index)
    end
    def to_bytes()
      bytes = super
      bytes += to_byte( @name_index, 2 )
      bytes += to_byte( @descriptor_index, 2 )
    end
    attr :name_index, true
    attr :descriptor_index, true
  end

  #
  #=== 文字列のConstant
  #
  class StringConstant < Constant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*string_index::値を示すconstant_poolのインデックス
    #
    def initialize( java_class, tag=nil, string_index=nil )
      super(java_class, tag)
      @string_index = string_index
    end
    #
    #=== 値を取得する
    #
    #<b>戻り値</b>::値
    #
    def bytes
      @java_class.get_constant_value(@string_index)
    end
    def to_bytes()
      tmp = super
      tmp += to_byte( @string_index, 2)
    end
    def to_s
      bytes != nil ? "\"#{bytes}\"" : "null"
    end
    attr :string_index, true
  end

  #
  #=== 文字列のConstant
  #
  class UTF8Constant < Constant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*bytes::値
    #
    def initialize( java_class, tag=nil, bytes=nil )
      super(java_class, tag)
      @bytes = bytes
    end
    def to_bytes()
      tmp = super
      body = []
      @bytes.each_byte {|i|
        body += to_byte( i, 1 )
      }
      tmp += to_byte( body.length, 2 )
      tmp += body
    end
    def to_s
      "\"#{bytes}\""
    end
    attr :bytes, true
  end

  #
  #=== 整数のConstant
  #
  class IntegerConstant < Constant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*bytes::値
    #
    def initialize( java_class, tag=nil, bytes=nil )
      super(java_class, tag)
      @bytes = bytes
    end
    def bytes()
      IntegerConstant::value_from_bytes(@bytes)
    end
    def bytes=(value)
      @bytes = IntegerConstant::bytes_from_value(value)
    end
    def to_bytes()
      tmp = super
      tmp += to_byte( @bytes, 4 )
    end
    def to_s
      bytes.to_s
    end
  private
    def self.value_from_bytes(bytes)
      return nil if bytes == nil
      e = bytes & 0x7FFFFFFF
      value = ((bytes >> 31) == 0) ? e : e - 0x80000000
      return value  
    end
    def self.bytes_from_value(value)
      return nil if value == nil
      if value > 2147483647 || value < -2147483648
        raise RangeError.new
      end
      tmp = value >= 0 ? value : 0x80000000 + value
      tmp |= (value >= 0 ? 0 : 1) << 31
    end
  end

  #
  #=== FloatのConstant
  #
  class FloatConstant < Constant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*bytes::値
    #
    def initialize( java_class, tag=nil, bytes=nil )
      super(java_class, tag)
      @bytes = bytes
    end
    def bytes()
      FloatConstant.value_from_bytes(@bytes)
    end
    def bytes=(value)
      raise "not implements yet."
    end
    def to_bytes()
      tmp = super
      tmp += to_byte( @bytes, 4)
    end
    def to_s
      tmp = bytes
      str =tmp.to_s
      str << "F" unless ( tmp.kind_of?(Float) && (tmp.nan? || tmp.infinite? ))
      return str
    end
  private
    def self.value_from_bytes(bytes)
      return nil if bytes == nil
      return  1.0/0   if bytes == 0x7f800000
      return -1.0/0   if bytes == 0xff800000
      return  0.0/0.0 if bytes >= 0x7f800001 && bytes <= 0x7fffffff
      return  0.0/0.0 if bytes >= 0xff800001 && bytes <= 0xffffffff
      s = ((bytes >> 31) == 0) ? 1 : -1
      e = ((bytes >> 23) & 0xff)
      m = (e == 0) ? ((bytes & 0x7fffff) << 1) : ((bytes & 0x7fffff) | 0x800000)
      return s*m*(2**(e-150))
    end
  end

  #
  #=== LongのConstant
  #
  class LongConstant < Constant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*bytes::値
    #
    def initialize( java_class, tag=nil, bytes=nil )
      super(java_class, tag)
      @bytes = bytes
    end
    def bytes()
      LongConstant::value_from_bytes(@bytes)
    end
    def bytes=(value)
      @bytes = LongConstant::bytes_from_value(value) # TODO
    end
    def to_bytes()
      tmp = super
      tmp += to_byte( @bytes, 8)
    end
    def to_s
      bytes.to_s << "L"
    end
  private
    def self.value_from_bytes(bytes)
      return nil if bytes == nil
      e = bytes & 0x7FFFFFFFFFFFFFFF
      value = ((bytes >> 63) == 0) ? e : e - 0x8000000000000000
      return value 
    end
    def self.bytes_from_value(value)
      return nil if value == nil
      if value > 9223372036854775807 || value < -9223372036854775808
        raise RangeError.new
      end
      tmp = value >= 0 ? value : 0x8000000000000000 + value
      tmp |= (value >= 0 ? 0 : 1) << 63
    end
  end

  #
  #=== DoubleのConstant
  #
  class DoubleConstant < Constant
    #
    #===コンストラクタ
    #
    #*java_class::constantの所有者であるJavaクラス
    #*tag::constantの種類を示すタグ
    #*bytes::値
    #
    def initialize( java_class, tag=nil, bytes=nil )
      super(java_class, tag)
      @bytes = bytes
    end
    def bytes()
      DoubleConstant.value_from_bytes(@bytes)
    end
    def bytes=(value)
      raise "not implements yet." # TODO
    end
    def to_bytes()
      tmp = super
      tmp += to_byte( @bytes, 8)
    end
    def to_s
      tmp = bytes
      str =tmp.to_s
      str << "D" unless ( tmp.kind_of?(Float) && (tmp.nan? || tmp.infinite? ))
      return str
    end
  private
    def self.value_from_bytes(bytes)
      return nil if bytes == nil
      return  1.0/0   if bytes == 0x7ff0000000000000
      return -1.0/0   if bytes == 0xfff0000000000000
      return  0.0/0.0 if bytes >= 0x7ff0000000000001 && bytes <= 0x7fffffffffffffff
      return  0.0/0.0 if bytes >= 0xfff0000000000001 && bytes <= 0xffffffffffffffff
      s = ((bytes >> 63) == 0) ? 1 : -1
      e = ((bytes >> 52) & 0x7ff)
      m = (e == 0) ? ((bytes & 0xfffffffffffff) << 1 ) : ((bytes & 0xfffffffffffff) | 0x10000000000000)
      return s*m*(2**(e-1075))
    end
  end
end