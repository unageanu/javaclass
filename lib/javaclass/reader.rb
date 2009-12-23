require "javaclass/base"
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
      @array.slice!(0, length).pack("C*")
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
      java_class.fields << read_field( io, java_class )
    }

    # method
    methods_count = read( 2, io )
    methods_count.times {|i|
      java_class.methods << read_method( io, java_class )
    }

    # attribute
    read_attributes(io, java_class, java_class )

    return java_class
  end
 
  #
  #=== メソッドを読み込む
  #
  #*io::IO
  #*java_class::Javaクラス
  #
  def read_method( io, java_class )
    m = Method.new( java_class )
    m.access_flag = MethodAccessFlag.new(read( 2, io ))
    m.name_index = read( 2, io )
    m.descriptor_index = read( 2, io )
    read_attributes( io, java_class, m )
    return m
  end
  
  #
  #=== フィールドを読み込む
  #
  #*io::IO
  #*java_class::Javaクラス
  #
  def read_field( io, java_class )
    f = Field.new( java_class )
    f.access_flag = FieldAccessFlag.new(read( 2, io ))
    f.name_index = read( 2, io )
    f.descriptor_index = read( 2, io )
    read_attributes( io, java_class, f )
    return f
  end

  #
  #=== IOから指定したバイト数だけデータを読み込んで返す
  #
  #*size::読み込むバイト数
  #*io::IO
  #<b>戻り値</b>::データ
  #
  def read( size, io, unsigned=true )
    res = 0
    size.times{|i| 
      res = res << 8 | io.getc
    }
    if !unsigned 
      border = 0x80 << (8 * (size-1))
      mask =  0x7f
      (size-1).times { mask = mask << 8 | 0xff  }
      res = (res & border ) != 0  ? (res & mask ) -  border : res
    end
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
      raise "unknown constant_pool_tag. tag =" << tag.to_s
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
      readed = 0
      while( code_length > readed )
        readed += read_code( readed, io, java_class, codes )
      end
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
    when "StackMapTable"
      stack_map_frame_entries = []
      entry_count = read( 2, io )
      entry_count.times {
        stack_map_frame_entries << read_stack_map_frame_entry( io, java_class )
      }
      attr = StackMapTableAttribute .new( java_class, name_index, stack_map_frame_entries )
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
  
  #
  #=== スタックマップフレームを読み込む
  #
  #*io::IO
  #*java_class::Javaクラス
  #
  def read_stack_map_frame_entry( io, java_class  )
    frame_type = read( 1, io )
    if frame_type < 64
      return SameFrame.new( frame_type )
    elsif frame_type >= 64 && frame_type < 128
      variable_info = read_variable_info( io, java_class )
      return SameLocals1StackItemFrame.new( frame_type, [variable_info] )
    elsif frame_type == 247
      offset_delta = read( 2, io )
      variable_info = read_variable_info( io, java_class )
      return SameLocals1StackItemFrameExtended.new( 
        frame_type, offset_delta, [variable_info] )
    elsif frame_type >= 248 && frame_type < 251
      offset_delta = read( 2, io )
      return ChopFrame.new( frame_type, offset_delta  )
    elsif frame_type == 251
      offset_delta = read( 2, io )
      return SameFrameExtended.new( frame_type, offset_delta  )
    elsif frame_type >= 252 && frame_type < 255
      offset_delta = read( 2, io )
      variable_infos=[]
      (frame_type - 251).times {|i|
        variable_infos << read_variable_info( io, java_class )
      }
      return AppendFrame.new( frame_type, offset_delta, variable_infos )
    elsif frame_type == 255
      offset_delta = read( 2, io )
      local_size = read( 2, io )
      local_variable_infos=[]
      (local_size).times {|i|
        local_variable_infos << read_variable_info( io, java_class )
      }
      stack_size = read( 2, io )
      stack_variable_infos=[]
      (stack_size).times {|i|
        stack_variable_infos << read_variable_info( io, java_class )
      }
      return FullFrame.new( frame_type, offset_delta, local_variable_infos, stack_variable_infos )
    end
  end
  
  #
  #=== 変数情報を読み込む
  #
  #*io::IO
  #*java_class::Javaクラス
  #
  def read_variable_info( io, java_class  )
    tag = read( 1, io )
    case tag
      when 7
        return ObjectVariableInfo.new( tag, read( 2, io ) )
      when 8
        return UninitializedVariableInfo.new( tag, read( 2, io ) )
      else
        return VariableInfo.new( tag )
    end
  end
  
  #
  #=== コードを読み込む
  #
  #*index::code中での出現位置
  #*io::IO
  #*java_class::Javaクラス
  #*codes::コードを追加するバッファ
  #
  def read_code( index, io, java_class, codes )
    code = nil
    opcode = read( 1, io )
    case opcode
    when 0x19 # aload
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xBD # anewarray
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x3A # astore
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x10 # bipush
      operands = [
        Operand.new( "s1", read( 1, io, false ), "<n>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xC0 # checkcast
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x18 # dload
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x39 # dstore
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x17 # fload
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x38 # fstore
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xB4 # getfield
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xB2 # getstatic
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xA7 # goto
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xC8 # goto_w
      operands = [
        Operand.new( "s4", read( 4, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xA5 # if_acmpeq
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xA6 # if_acmpne
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x9F # if_icmpeq
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xA2 # if_icmpge
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xA3 # if_icmpgt
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xA4 # if_icmple
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xA1 # if_icmplt
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xA0 # if_icmpne
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x99 # ifeq
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x9C # ifge
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x9D # ifgt
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x9E # ifle
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x9B # iflt
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x9A # ifne
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xC7 # ifnonnull
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xC6 # ifnull
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branch-offset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x84 # iinc
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
        Operand.new( "s1", read( 1, io, false ), "<n>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x15 # iload
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xC1 # instanceof
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xB9 # invokeinterface
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
        Operand.new( "u1", read( 1, io ), "<n>"),
        Operand.new( "u1", read( 1, io ), "0"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xB7 # invokespecial
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xB8 # invokestatic
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xB6 # invokevirtual
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x36 # istore
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xA8 # jsr
      operands = [
        Operand.new( "s2", read( 2, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xC9 # jsr_w
      operands = [
        Operand.new( "s4", read( 4, io, false ), "branchoffset"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x12 # ldc
      operands = [
        Operand.new( "u1", read( 1, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x14 # ldc2_w
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x13 # ldc_w
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x16 # lload
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xAB # lookupswitch
      operands = []
      # 0 to 3 bytes of padding zeros
      ((index+1)%4 == 0 ? 0 :4-((index+1)%4)).times {|i|
        operands << Operand.new( "u1", read( 1, io ), "0 padding")
      }
      operands << Operand.new( "s4", read( 4, io, false ), "default_offset")
      n = read( 4, io, false )
      operands << Operand.new( "s4", n, "n")
      n.times {|i|
        operands << Operand.new( "s4", read( 4, io, false ), "key_#{i}")
        operands << Operand.new( "s4", read( 4, io, false ), "offset_#{i}")
      }
      code = Code.new( java_class, index, opcode, operands )
    when 0x37 # lstore
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xC5 # multianewarray
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
        Operand.new( "u1", read( 1, io ), "<n>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xBB # new
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xBC # newarray
      operands = [
        Operand.new( "u1", read( 1, io ), "array-type"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xB5 # putfield
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xB3 # putstatic
      operands = [
        Operand.new( "u2", read( 2, io ), "index"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xA9 # ret
      operands = [
        Operand.new( "u1", read( 1, io ), "<varnum>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0x11 # sipush
      operands = [
        Operand.new( "s2", read( 2, io, false ), "<n>"),
      ]
      code = Code.new( java_class, index, opcode, operands )
    when 0xAA # tableswitch
      operands = []
      # 0 to 3 bytes of padding zeros
      ((index+1)%4 == 0 ? 0 :4-((index+1)%4)).times {|i|
        operands << Operand.new( "u1", read( 1, io ), "0 padding")
      }
      operands << Operand.new( "s4", read( 4, io, false ), "default_offset")
      low = read( 4, io, false )
      hight = read( 4, io, false )
      operands << Operand.new( "s4", low,   "<low>")
      operands << Operand.new( "s4", hight, "<low> + N - 1")
      (hight-low+1).times {|i|
        operands << Operand.new( "s4", read( 4, io, false ), "offset_#{i}")
      }
      code = Code.new( java_class, index, opcode, operands )
    when 0xC4 # wide
      opcode = read( 1, io )
      case opcode
      when 0x19 # aload
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      when 0x3A # astore
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      when 0x18 # dload
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      when 0x39 # dstore
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      when 0x17 # fload
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      when 0x38 # fstore
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      when 0x84 # iinc
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
          Operand.new( "s2", read( 2, io, false ), "<n>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      when 0x15 # iload
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      when 0x36 # istore
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      when 0x16 # lload
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      when 0x37 # lstore
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      when 0xA9 # ret
        operands = [
          Operand.new( "u2", read( 2, io ), "<varnum>"),
        ]
        code = Code.new( java_class, index, opcode, operands, true )
      end
    else
      code = Code.new( java_class, index, opcode )
    end
    codes << code if code
    return code ? code.to_bytes.length : 1
  end
end