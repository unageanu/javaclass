require "javaclass/util"
require "stringio"

module JavaClass

  #
  #=== byte配列をIOに見せかける。
  #
  class ArrayIO
    def initialize( array )
      @array = array
    end
    def getc
      @array.shift
    end
    def read(length)
      @array[0..length].pack("C*")
    end    
  end  
  
module_function

	#
	#===IOまたはバイト配列からクラスを読み込む。
	#
	#*io::IOまたはバイト配列。(IO.getc,IO.read(length)が実装されていればOK)
	#<b>戻り値</b>::クラス
	#
	def from( src )
    
	  if ( src.kind_of?(Array) ) 
      io = ArrayIO.new(src) 
    else
      io = src
	  end
    
	  # magic
	  raise "illegal class data." if read( 4, io ) != 0xCAFEBABE

    java_class = JavaClass::Class.new

    # version
    java_class.minor_version = read( 2, io )
    java_class.major_version = read( 2, io )

    # constant_pool
    constant_pool_count = read( 2, io )
    index = 1
    while( index < constant_pool_count)
      java_class.constant_pool[index] = read_constant(io, java_class)

      # constantがdouble or longの場合、次のindexは欠番。
      tag = java_class.constant_pool[index].tag
      if tag == JavaClass::Constant::CONSTANT_Double \
        || tag == JavaClass::Constant::CONSTANT_Long
        index += 1
      end
      index += 1
    end

    # access_flag
    access_flag = read( 2, io )
    java_class.access_flag = ClassAccessFlag.new(access_flag)

    # class
    java_class.this_class_index  = read( 2, io )
    java_class.super_class_index = read( 2, io )
    interfaces_count = read( 2, io )
    interfaces_count.times{|i|
      java_class.interface_indexs << read( 2, io )
    }

    # field
    fields_count = read( 2, io )
    fields_count.times {|i|
      f = Field.new( java_class )
      f.access_flag = FieldAccessFlag.new(read( 2, io ))
      f.name_index = read( 2, io )
      f.descriptor_index = read( 2, io )
      read_attributes(io, java_class, f )
      java_class.fields << f
    }

    # method
    methods_count = read( 2, io )
    methods_count.times {|i|
      m = Method.new( java_class )
      m.access_flag = MethodAccessFlag.new(read( 2, io ))
      m.name_index = read( 2, io )
      m.descriptor_index = read( 2, io )
      read_attributes(io, java_class, m )
      java_class.methods << m
    }

    # attribute
    read_attributes(io, java_class, java_class )

    return java_class
	end

  #
  #=== IOから指定したバイト数だけデータを読み込んで返す
  #
  #*size::読み込むだバイト数
  #*io::IO
  #<b>戻り値</b>::データ
  #
  def read( size, io )
    res = 0
    size.times{|i| res = res << 8 | io.getc }
    return res
  end

  #
  #===IOからconstantを読み込む。
  #
  #*io::IO。IO.getcが実装されていればOK
  #*java_class::constantの所有者であるJavaクラス
  #<b>戻り値</b>::クラス
  #
  def read_constant(io, java_class)
    tag = read( 1, io )
    case tag
    when JavaClass::Constant::CONSTANT_Class
      name_index = read( 2, io )
      cp = ClassConstant.new( java_class, tag, name_index )
    when JavaClass::Constant::CONSTANT_Fieldref, \
      JavaClass::Constant::CONSTANT_Methodref, JavaClass::Constant::CONSTANT_InterfaceMethodref
      class_name_index    = read( 2, io )
      name_and_type_index = read( 2, io )
      case tag
      when JavaClass::Constant::CONSTANT_Fieldref
        cp = FieldRefConstant.new( java_class, tag, \
          class_name_index, name_and_type_index )
      when JavaClass::Constant::CONSTANT_Methodref
        cp = MethodRefConstant.new( java_class, tag, \
          class_name_index, name_and_type_index )
      when JavaClass::Constant::CONSTANT_InterfaceMethodref
        cp = InterfaceMethodRefConstant.new( java_class, tag, \
          class_name_index, name_and_type_index )
      end
    when JavaClass::Constant::CONSTANT_NameAndType
      name_index       = read( 2, io )
      descriptor_index = read( 2, io )
      cp = NameAndTypeConstant.new( java_class, tag, name_index, descriptor_index )
    when JavaClass::Constant::CONSTANT_String
      string_index = read( 2, io )
      cp = StringConstant.new( java_class, tag, string_index )
    when JavaClass::Constant::CONSTANT_Integer
      bytes = read( 4, io )
      cp = IntegerConstant.new( java_class, tag, bytes )
    when JavaClass::Constant::CONSTANT_Float
      bytes = read( 4, io )
      cp = FloatConstant.new( java_class, tag, bytes )
    when JavaClass::Constant::CONSTANT_Long
      bytes = read( 8, io )
      cp = LongConstant.new( java_class, tag, bytes )
    when JavaClass::Constant::CONSTANT_Double
      bytes = read( 8, io )
      cp = DoubleConstant.new( java_class, tag, bytes )
    when JavaClass::Constant::CONSTANT_Utf8
      length = read( 2, io )
      bytes = io.read(length)
      cp = UTF8Constant.new( java_class, tag, bytes )
    else
      raise "unkown constant_pool_tag. tag =" << tag.to_s
    end
    return cp
  end

  #
  #=== 属性を読み込む
  #
  #*io::IO
  #*java_class::Javaクラス
  #*owner::属性の所有者
  #
  def read_attributes( io, java_class, owner )
    count = read( 2, io )
    count.times {|i|
      attr = read_attribute( io, java_class )
      owner.attributes[attr.name] = attr
    }
  end
  #
  #=== 属性を読み込む
  #
  #*io::IO
  #*java_class::Javaクラス
  #
  def read_attribute( io, java_class )

    # 名前
    name_index = read( 2, io )
    name   = java_class.get_constant_value( name_index )
    length = read( 4, io )
    attr = nil
    case name
    when "ConstantValue"
      constant_value_index = read( 2, io )
      attr = ConstantValueAttribute.new( java_class, name_index, constant_value_index )
    when "Exceptions"
      exception_index_table = []
      number_of_exceptions = read( 2, io )
      number_of_exceptions.times {
        exception_index_table << read( 2, io )
      }
      attr = ExceptionsAttribute.new( java_class, name_index, exception_index_table )
    when "InnerClasses"
      classes = []
      number_of_classes = read( 2, io )
      number_of_classes.times {
        classes << read_inner_class( io, java_class )
      }
      attr = InnerClassesAttribute.new( java_class, name_index, classes )
    when "EnclosingMethod"
      class_index = read( 2, io )
      method_index = read( 2, io )
      attr = EnclosingMethodAttribute.new( java_class, name_index, class_index, method_index )
    when "SourceFile"
      source_file_index = read( 2, io )
      attr = SourceFileAttribute.new( java_class, name_index, source_file_index )
    when "SourceDebugExtension"
      debug_extension = io.read(length)
      attr = SourceDebugExtensionAttribute.new( java_class, name_index, debug_extension )
    when "AnnotationDefault"
      value = read_annotation_element_value( io, java_class )
      attr = AnnotationDefaultAttribute.new( java_class, name_index, value )
    when "Signature"
      signature_index = read( 2, io )
      attr = SignatureAttribute.new( java_class, name_index, signature_index )
    when "Deprecated"
      attr = DeprecatedAttribute.new( java_class, name_index )
    when "Synthetic"
      attr = SyntheticAttribute.new( java_class, name_index )
    when "RuntimeVisibleAnnotations", "RuntimeInvisibleAnnotations"
      annotations = read_annotations( io, java_class )
      attr = AnnotationsAttribute.new( java_class, name_index, annotations )
    when "RuntimeVisibleParameterAnnotations", "RuntimeInvisibleParameterAnnotations"
      params = []
      num_parameters = read( 1, io )
      num_parameters.times {
        params << read_annotations( io, java_class )
      }
      attr = ParameterAnnotationsAttribute.new( java_class, name_index, params )
    when "AnnotationDefault"
      value = read_annotation_element_value( io, java_class )
      attr = AnnotationDefaultAttribute.new( java_class, name_index, value )
    when "Code"
      max_stack = read( 2, io )
      max_locals = read( 2, io )
      codes = []
      code_length = read( 4, io )
      code_length.times {
        codes << read( 1, io )
      }
      exception_table = []
      exception_table_length = read( 2, io )
      exception_table_length.times {
        exception_table << read_exception( io, java_class )
      }
      attr = CodeAttribute.new( java_class, name_index, max_stack, \
        max_locals, codes, exception_table, {} )
      read_attributes( io, java_class, attr )
    when "LineNumberTable"
      line_number_table = []
      line_number_table_length = read( 2, io )
      line_number_table_length.times {
        line_number_table << read_line_number( io, java_class )
      }
      attr = LineNumberTableAttribute.new( java_class, name_index, line_number_table )
    when "LocalVariableTable"
      local_variable_table = []
      local_variable_table_length = read( 2, io )
      local_variable_table_length.times {
        local_variable_table << read_local_variable( io, java_class )
      }
      attr = LocalVariableTableAttribute.new( java_class, name_index, local_variable_table )
    when "LocalVariableTypeTable"
      local_variable_type_table = []
      local_variable_type_table_length = read( 2, io )
      local_variable_type_table_length.times {
        local_variable_type_table << read_local_variable_type( io, java_class )
      }
      attr = LocalVariableTypeTableAttribute.new( java_class, name_index, local_variable_type_table )
    else
      read( length, io ) # 読み飛ばす。
      attr = Attribute.new( java_class, name_index )
    end
    return attr
  end

  #
  #=== インナークラスを読み込む
  #
  #*io::IO
  #*java_class::Javaクラス
  #
  def read_inner_class( io, java_class )
    inner_class_info_index = read( 2, io )
    outer_class_info_index = read( 2, io )
    inner_name_index = read( 2, io )
    inner_class_access_flags = InnerClassAccessFlag.new( read( 2, io ) )
    return InnerClass.new( java_class, inner_class_info_index,
      outer_class_info_index, inner_name_index, inner_class_access_flags )
  end

  #
  #=== アノテーションを読み込む
  #
  #*io::IO
  #*java_class::Javaクラス
  #
  def read_annotations( io, java_class )
    annotations = []
    num_annotations = read( 2, io )
    num_annotations.times {|i|
      annotations << read_annotation( io, java_class )
    }
    return annotations
  end

  #
  #=== アノテーションを読み込む
  #
  #*io::IO
  #*java_class::Javaクラス
  #
  def read_annotation( io, java_class )
    elements = {}
    type_index = read( 2, io )
    num_element_value_pairs = read( 2, io )
    num_element_value_pairs.times {|i|
      e = read_annotation_element( io, java_class )
      elements[e.name] = e
    }
    return Annotation.new( java_class, type_index, elements )
  end

  #
  #=== アノテーションデータを読み込む
  #
  #*io::IO
  #*java_class::Javaクラス
  #
  def read_annotation_element( io, java_class )
    element_name_index = read( 2, io )
    value = read_annotation_element_value( io, java_class )
    return AnnotationElement.new( java_class, element_name_index, value )
  end

  #
  #=== アノテーションデータを読み込む
  #
  #*io::IO
  #*java_class::Javaクラス
  #
  def read_annotation_element_value( io, java_class )
    tag = read( 1, io )
    value = nil
    case tag.chr
    when 'B', 'C', 'D', 'F', 'I', 'J', 'S', 'Z', 's'
      const_value_index = read( 2, io )
      value = ConstAnnotationElementValue.new( java_class, tag, const_value_index )
    when 'e'
      type_name_index = read( 2, io )
      const_name_index = read( 2, io )
      value = EnumAnnotationElementValue.new( java_class, tag, type_name_index, const_name_index )
    when 'c'
      class_info_index = read( 2, io )
      value = ClassAnnotationElementValue.new( java_class, tag, class_info_index )
    when '@'
      annotation = read_annotation( io, java_class )
      value = AnnotationAnnotationElementValue.new( java_class, tag, annotation )
    when '['
      array = []
      num_values = read( 2, io )
      num_values.times{|i|
        array << read_annotation_element_value( io, java_class )
      }
      value = ArrayAnnotationElementValue.new( java_class, tag, array )
    end
    return value
  end

  #
  #=== メソッドの例外を読み込む
  #
  def read_exception( io, java_class )
    start_pc = read( 2, io )
    end_pc = read( 2, io )
    handler_pc = read( 2, io )
    catch_type = read( 2, io )
    return Excpetion.new( java_class, start_pc, end_pc, handler_pc, catch_type )
  end

  #
  #=== 行番号を読み込む
  #
  def read_line_number( io, java_class )
    start_pc = read( 2, io )
    line_number = read( 2, io )
    return LineNumber.new( java_class, start_pc, line_number )
  end

  #
  #=== メソッドのローカル変数を読み込む
  #
  def read_local_variable( io, java_class )
    start_pc = read( 2, io )
    length = read( 2, io )
    name_index = read( 2, io )
    descriptor_index = read( 2, io )
    index = read( 2, io )
    return LocalVariable.new( java_class, \
      start_pc, length, name_index, descriptor_index, index )
  end
  #
  #=== メソッドのローカル変数の型を読み込む
  #
  def read_local_variable_type( io, java_class )
    start_pc = read( 2, io )
    length = read( 2, io )
    name_index = read( 2, io )
    signature_index = read( 2, io )
    index = read( 2, io )
    return LocalVariableType.new( java_class, \
      start_pc, length, name_index, signature_index, index )
  end
end