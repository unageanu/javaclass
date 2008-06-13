#!/usr/bin/ruby

$: << "../src"

require "runit/testcase"
require "runit/cui/testrunner"

require "javaclass"
require "test-util"

module JavaClass
  
  #
  #=== Attributesのテスト
  #
  class AttributeTest <  RUNIT::TestCase
    
    include TestUtil
    
    def setup
      @java_class = JavaClass::Class.new
      
      @java_class.constant_pool[1]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "ConstantValue" )
      @java_class.constant_pool[2]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "Exceptions" )
      @java_class.constant_pool[3]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "InnerClasses" )
      @java_class.constant_pool[4]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "EnclosingMethod" )
      @java_class.constant_pool[5]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "Deprecated" )
      @java_class.constant_pool[6]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "Synthetic" )
      @java_class.constant_pool[7]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "SourceFile" )
      @java_class.constant_pool[8]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "SourceDebugExtension" )
      @java_class.constant_pool[9]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "Signature" )
      @java_class.constant_pool[10]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "RuntimeVisibleAnnotations" )
      @java_class.constant_pool[11]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "RuntimeInvisibleParameterAnnotations" )
      @java_class.constant_pool[12]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "AnnotationDefault" )
      @java_class.constant_pool[13]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "Code" )
      @java_class.constant_pool[14]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "LineNumberTable" )
      @java_class.constant_pool[15]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "LocalVariableTable" )
      @java_class.constant_pool[16]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "LocalVariableTypeTable" )

      @java_class.constant_pool[30]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "aaa" )
      @java_class.constant_pool[31]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "bbb" )
      @java_class.constant_pool[32]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "ccc" )
      
      @java_class.constant_pool[40] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "com/foo/Hoge" )
      @java_class.constant_pool[41] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "com/foo/Var" )
      @java_class.constant_pool[42] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "com/foo/Piyo" )
      @java_class.constant_pool[43] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "java/lang/Exception" )
      @java_class.constant_pool[44] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "java/lang/Throwable" )
      @java_class.constant_pool[45] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "com/foo/HogeException" )
      @java_class.constant_pool[46] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "FOO" )
      @java_class.constant_pool[47] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "VAR" )
      @java_class.constant_pool[48] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "Lcom/foo/Hoge;" )
      @java_class.constant_pool[49] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "Lcom/foo/Var;" )
      
      @java_class.constant_pool[50] = IntegerConstant.new( @java_class, Constant::CONSTANT_Integer, 0 )
      @java_class.constant_pool[51] = IntegerConstant.new( @java_class, Constant::CONSTANT_Integer, 10 )
      @java_class.constant_pool[52] = IntegerConstant.new( @java_class, Constant::CONSTANT_Integer, 100 )
      
      @java_class.constant_pool[100] = ClassConstant.new( @java_class, Constant::CONSTANT_Class, 40 )
      @java_class.constant_pool[101] = ClassConstant.new( @java_class, Constant::CONSTANT_Class, 41 )
      @java_class.constant_pool[102] = ClassConstant.new( @java_class, Constant::CONSTANT_Class, 42 )
      @java_class.constant_pool[103] = ClassConstant.new( @java_class, Constant::CONSTANT_Class, 43 )
      @java_class.constant_pool[104] = ClassConstant.new( @java_class, Constant::CONSTANT_Class, 44 )
      @java_class.constant_pool[105] = ClassConstant.new( @java_class, Constant::CONSTANT_Class, 45 )
    
      @java_class.constant_pool[120] = NameAndTypeConstant.new( @java_class, Constant::CONSTANT_NameAndType, 30, 40 )
      @java_class.constant_pool[121] = NameAndTypeConstant.new( @java_class, Constant::CONSTANT_NameAndType, 31, 41 )
    end
  
    def teardown
    end
    
    #
    #=== LocalVariableTypeTableAttributeのテスト
    #
    def test_LocalVariableTypeTableAttribute
      
      lvs = [
        LocalVariableType.new( @java_class, 2, 12, 30, 48, 1 ),
        LocalVariableType.new( @java_class, 5,  8, 31, 49, 3 )
      ]
      attr = LocalVariableTypeTableAttribute.new( @java_class, 16, lvs )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "LocalVariableTypeTable"
        assert_equals a.local_variable_type_table, lvs
        assert_equals a.find_by_index(1), lvs[0]
        assert_equals a.find_by_index(3), lvs[1]
        assert_equals a.find_by_index(100), nil
        assert_equals a.dump, "00100000 00160002 0002000C 001E0030\n00010005 0008001F 00310003"
        assert_equals a.to_bytes, [0x00, 0x10, 0x00, 0x00, 0x00, 0x16, 0x00, 0x02, 0x00, 0x02, 0x00, 0x0C, 0x00, 0x1E, 0x00, 0x30, 0x00, 0x01, 0x00, 0x05, 0x00, 0x08, 0x00, 0x1F, 0x00, 0x31, 0x00, 0x03]
      }

      lvs = [LocalVariableType.new( @java_class, 5,  8, 31, 49, 3 )]
      attr.local_variable_type_table = lvs
      assert_attribute( attr ) {|a|
        assert_equals a.name, "LocalVariableTypeTable"
        assert_equals a.local_variable_type_table, lvs
        assert_equals a.find_by_index(1), nil
        assert_equals a.find_by_index(3), lvs[0]
        assert_equals a.find_by_index(100), nil
        assert_equals a.dump, "00100000 000C0001 00050008 001F0031\n0003"
        assert_equals a.to_bytes, [0x00, 0x10, 0x00, 0x00, 0x00, 0x0C, 0x00, 0x01, 0x00, 0x05, 0x00, 0x08, 0x00, 0x1F, 0x00, 0x31, 0x00, 0x03]
      }
    end
    
    #
    #=== LocalVariableTypeのテスト
    #
    def test_LocalVariableType
      
      lv = LocalVariableType.new( @java_class, 2, 12, 30, 48, 1 )
      assert_local_variable_type( lv ) {|a|
        #assert_equals a.to_s, "com.foo.Hoge aaa"
        assert_equals a.start_pc, 2
        assert_equals a.length, 12
        assert_equals a.name, "aaa"
        assert_equals a.name_index, 30
        assert_equals a.signature, "Lcom/foo/Hoge;"
        assert_equals a.signature_index, 48
        assert_equals a.index, 1
        assert_equals a.dump, "0002000C 001E0030 0001"
        assert_equals a.to_bytes, [0x00, 0x02, 0x00, 0x0C, 0x00, 0x1E, 0x00, 0x30, 0x00, 0x01]
      }

      lv.start_pc = 8
      lv.length = 5
      lv.name_index = 31
      lv.signature_index = 49
      lv.index = 3
      assert_local_variable_type( lv ) {|a|
        #assert_equals a.to_s, "com.foo.Var bbb"
        assert_equals a.start_pc, 8
        assert_equals a.length, 5
        assert_equals a.name, "bbb"
        assert_equals a.name_index, 31
        assert_equals a.signature, "Lcom/foo/Var;"
        assert_equals a.signature_index, 49
        assert_equals a.index, 3
        assert_equals a.dump, "00080005 001F0031 0003"
        assert_equals a.to_bytes, [0x00, 0x08, 0x00, 0x05, 0x00, 0x1F, 0x00, 0x31, 0x00, 0x03]
      }
    end
    
    #
    #=== LocalVariableTableAttributeのテスト
    #
    def test_LocalVariableTableAttribute
      
      lvs = [
        LocalVariable.new( @java_class, 2, 12, 30, 48, 1 ),
        LocalVariable.new( @java_class, 5,  8, 31, 49, 3 )
      ]
      attr = LocalVariableTableAttribute.new( @java_class, 15, lvs )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "LocalVariableTable"
        assert_equals a.local_variable_table, lvs
        assert_equals a.find_by_index(1), lvs[0]
        assert_equals a.find_by_index(3), lvs[1]
        assert_equals a.find_by_index(100), nil
        assert_equals a.dump, "000F0000 00160002 0002000C 001E0030\n00010005 0008001F 00310003"
        assert_equals a.to_bytes, [0x00, 0x0F, 0x00, 0x00, 0x00, 0x16, 0x00, 0x02, 0x00, 0x02, 0x00, 0x0C, 0x00, 0x1E, 0x00, 0x30, 0x00, 0x01, 0x00, 0x05, 0x00, 0x08, 0x00, 0x1F, 0x00, 0x31, 0x00, 0x03]
      }

      lvs = [LocalVariable.new( @java_class, 5,  8, 31, 49, 3 )]
      attr.local_variable_table = lvs
      assert_attribute( attr ) {|a|
        assert_equals a.name, "LocalVariableTable"
        assert_equals a.local_variable_table, lvs
        assert_equals a.find_by_index(1), nil
        assert_equals a.find_by_index(3), lvs[0]
        assert_equals a.find_by_index(100), nil
        assert_equals a.dump, "000F0000 000C0001 00050008 001F0031\n0003"
        assert_equals a.to_bytes, [0x00, 0x0F, 0x00, 0x00, 0x00, 0x0C, 0x00, 0x01, 0x00, 0x05, 0x00, 0x08, 0x00, 0x1F, 0x00, 0x31, 0x00, 0x03]
      }
    end
    
    #
    #=== LocalVariableのテスト
    #
    def test_LocalVariable
      
      lv = LocalVariable.new( @java_class, 2, 12, 30, 48, 1 )
      assert_local_variable( lv ) {|a|
        assert_equals a.to_s, "com.foo.Hoge aaa"
        assert_equals a.start_pc, 2
        assert_equals a.length, 12
        assert_equals a.name, "aaa"
        assert_equals a.name_index, 30
        assert_equals a.descriptor, "Lcom/foo/Hoge;"
        assert_equals a.descriptor_index, 48
        assert_equals a.index, 1
        assert_equals a.dump, "0002000C 001E0030 0001"
        assert_equals a.to_bytes, [0x00, 0x02, 0x00, 0x0C, 0x00, 0x1E, 0x00, 0x30, 0x00, 0x01]
      }

      lv.start_pc = 8
      lv.length = 5
      lv.name_index = 31
      lv.descriptor_index = 49
      lv.index = 3
      assert_local_variable( lv ) {|a|
        assert_equals a.to_s, "com.foo.Var bbb"
        assert_equals a.start_pc, 8
        assert_equals a.length, 5
        assert_equals a.name, "bbb"
        assert_equals a.name_index, 31
        assert_equals a.descriptor, "Lcom/foo/Var;"
        assert_equals a.descriptor_index, 49
        assert_equals a.index, 3
        assert_equals a.dump, "00080005 001F0031 0003"
        assert_equals a.to_bytes, [0x00, 0x08, 0x00, 0x05, 0x00, 0x1F, 0x00, 0x31, 0x00, 0x03]
      }
    end
    
    #
    #=== LineNumberTableAttributeのテスト
    #
    def test_LineNumberTableAttribute
      
      lns = [
        LineNumber.new( @java_class, 2, 5 ),
        LineNumber.new( @java_class, 8, 9 ),
        LineNumber.new( @java_class, 12, 15 )
      ]
      attr = LineNumberTableAttribute.new( @java_class, 14, lns )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "LineNumberTable"
        assert_equals a.line_numbers, lns
        assert_equals a.line_number(8), LineNumber.new( @java_class, 8, 9 )
        assert_equals a.line_number(1000), nil
        assert_equals a.dump, "000E0000 000E0003 00020005 00080009\n000C000F"
        assert_equals a.to_bytes, [0x00, 0x0E, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x03, 0x00, 0x02, 0x00, 0x05, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0C, 0x00, 0x0F]
      }

      attr.line_numbers = []
      assert_attribute( attr ) {|a|
        assert_equals a.name, "LineNumberTable"
        assert_equals a.line_numbers, []
        assert_equals a.line_number(8), nil
        assert_equals a.line_number(1000), nil
        assert_equals a.dump, "000E0000 00020000"
        assert_equals a.to_bytes, [0x00, 0x0E, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00]
      }
    end
    
    #
    #=== LineNumberのテスト
    #
    def test_LineNumber
      
      ln = LineNumber.new( @java_class, 12, 15 )
      assert_line_number( ln ) {|a|
        assert_equals a.to_s, "line : 15"
        assert_equals a.start_pc, 12
        assert_equals a.line_number, 15
        assert_equals a.dump, "000C000F"
        assert_equals a.to_bytes, [0x00, 0x0C, 0x00, 0x0F]
      }

      ln.start_pc = 8
      ln.line_number = 5
      assert_line_number( ln ) {|a|
        assert_equals a.to_s, "line : 5"
        assert_equals a.start_pc, 8
        assert_equals a.line_number, 5
        assert_equals a.dump, "00080005"
        assert_equals a.to_bytes, [0x00, 0x08, 0x00, 0x05]
      }
    end
    
    #
    #=== CodeAttributeのテスト
    #
    def test_CodeAttribute
      
      exceptions = [Excpetion.new( @java_class, 1, 10, 16, 103 )]
      attr = CodeAttribute.new( @java_class, 13, 10, 8, [0x05, 0x06], exceptions, {} )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "Code"
        assert_equals a.max_stack, 10
        assert_equals a.max_locals, 8
        assert_equals a.codes, [0x05, 0x06]
        assert_equals a.exception_table, exceptions
        assert_equals a.attributes, {}
        assert_equals a.dump, "000D0000 0016000A 00080000 00020506\n00010001 000A0010 00670000"
        assert_equals a.to_bytes, [0x00, 0x0D, 0x00, 0x00, 0x00, 0x16, 0x00, 0x0A, 0x00, 0x08, 0x00, 0x00, 0x00, 0x02, 0x05, 0x06, 0x00, 0x01, 0x00, 0x01, 0x00, 0x0A, 0x00, 0x10, 0x00, 0x67, 0x00, 0x00]
      }

      exceptions = [
        Excpetion.new( @java_class, 1, 10, 16, 103 ),
        Excpetion.new( @java_class, 5, 20, 16, 104 )
      ]
      attr.exception_table = exceptions
      attr.max_stack = 20
      attr.max_locals = 11
      attr.codes = []
      attr.attributes["RuntimeVisibleAnnotations"]  = AnnotationsAttribute.new( @java_class, 10, [Annotation.new( @java_class, 48 )] )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "Code"
        assert_equals a.max_stack, 20
        assert_equals a.max_locals, 11
        assert_equals a.codes, []
        assert_equals a.exception_table, exceptions
        assert_equals a.attributes, {
          "RuntimeVisibleAnnotations"=> AnnotationsAttribute.new( @java_class, 10, [Annotation.new( @java_class, 48 )] )
        }
        assert_equals a.dump, "000D0000 00280014 000B0000 00000002\n0001000A 00100067 00050014 00100068\n0001000A 00000006 00010030 0000"
        assert_equals a.to_bytes, [0x00, 0x0D, 0x00, 0x00, 0x00, 0x28, 0x00, 0x14, 0x00, 0x0B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0x00, 0x0A, 0x00, 0x10, 0x00, 0x67, 0x00, 0x05, 0x00, 0x14, 0x00, 0x10, 0x00, 0x68, 0x00, 0x01, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00, 0x01, 0x00, 0x30, 0x00, 0x00]
      }
    end
    
    #
    #=== Excpetionのテスト
    #
    def test_Excpetion
      
      ex = Excpetion.new( @java_class, 1, 10, 16, 103 )
      assert_exception( ex ) {|a|
        assert_equals a.catch_type, @java_class.constant_pool[103]
        assert_equals a.start_pc, 1
        assert_equals a.end_pc, 10
        assert_equals a.handler_pc, 16
        assert_equals a.catch_type_index, 103
        assert_equals a.dump, "0001000A 00100067"
        assert_equals a.to_bytes, [0x00, 0x01, 0x00, 0x0A, 0x00, 0x10, 0x00, 0x67]
      }

      ex.start_pc = 3
      ex.end_pc =  5
      ex.handler_pc = 15
      ex.catch_type_index = 0
      assert_exception( ex ) {|a|
        assert_equals a.catch_type, nil
        assert_equals a.start_pc, 3
        assert_equals a.end_pc, 5
        assert_equals a.handler_pc, 15
        assert_equals a.catch_type_index, 0
        assert_equals a.dump, "00030005 000F0000"
        assert_equals a.to_bytes, [0x00, 0x03, 0x00, 0x05, 0x00, 0x0F, 0x00, 0x00]     
      }
    end
    
    #
    #=== AnnotationDefaultAttributeのテスト
    #
    def test_AnnotationDefaultAttribute
      
      value = ConstAnnotationElementValue.new( @java_class, 's'[0], 30 )
      attr = AnnotationDefaultAttribute.new( @java_class, 12, value )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "AnnotationDefault"
        assert_equals a.to_s, "default \"aaa\""
        assert_equals a.element_value, value
        assert_equals a.dump, "000C0000 00037300 1E"
        assert_equals a.to_bytes, [0x00, 0x0C, 0x00, 0x00, 0x00, 0x03, 0x73, 0x00, 0x1E]
      }

      value = ConstAnnotationElementValue.new( @java_class, 's'[0], 31 )
      attr.element_value = value
      assert_attribute( attr ) {|a|
        assert_equals a.name, "AnnotationDefault"
        assert_equals a.to_s, "default \"bbb\""
        assert_equals a.element_value, value
        assert_equals a.dump, "000C0000 00037300 1F"
        assert_equals a.to_bytes, [0x00, 0x0C, 0x00, 0x00, 0x00, 0x03, 0x73, 0x00, 0x1F]      }
    end

    #
    #=== ParameterAnnotationsAttributeのテスト
    #
    def test_ParameterAnnotationsAttribute
      
      annotationsA = [
        Annotation.new( @java_class, 48 ),
        Annotation.new( @java_class, 49 )
      ]
      annotationsB = [
        Annotation.new( @java_class, 48 )
      ]
      
      attr = ParameterAnnotationsAttribute.new( @java_class, 11, [
        annotationsA, [], annotationsB
      ] )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "RuntimeInvisibleParameterAnnotations"
        assert_equals a[0], annotationsA
        assert_equals a[1], []
        assert_equals a[2], annotationsB
        assert_equals a.dump, "000B0000 00130300 02003000 00003100\n00000000 01003000 00"
        assert_equals a.to_bytes, [0x00, 0x0B, 0x00, 0x00, 0x00, 0x13, 0x03, 0x00, 0x02, 0x00, 0x30, 0x00, 0x00, 0x00, 0x31, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x30, 0x00, 0x00]
      }
      
      attr[1] << Annotation.new( @java_class, 48 )
      attr[0] = []
      assert_attribute( attr ) {|a|
        assert_equals a.name, "RuntimeInvisibleParameterAnnotations"
        assert_equals a[0], []
        assert_equals a[1], [Annotation.new( @java_class, 48 )]
        assert_equals a[2], annotationsB
        assert_equals a.dump, "000B0000 000F0300 00000100 30000000\n01003000 00"
        assert_equals a.to_bytes, [0x00, 0x0B, 0x00, 0x00, 0x00, 0x0F, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x30, 0x00, 0x00, 0x00, 0x01, 0x00, 0x30, 0x00, 0x00]
      }
    end

    #
    #=== AnnotationAttributeのテスト
    #
    def test_AnnotationsAttribute
      
      annotations = [
        Annotation.new( @java_class, 48, {
          "aaa"=> AnnotationElement.new( @java_class, 30, ConstAnnotationElementValue.new( @java_class, 's'[0], 30 )),
          "bbb"=> AnnotationElement.new( @java_class, 31, ConstAnnotationElementValue.new( @java_class, 'I'[0], 51 )),
        } ),
        Annotation.new( @java_class, 49, {
          "bbb"=> AnnotationElement.new( @java_class, 31, ConstAnnotationElementValue.new( @java_class, 'I'[0], 51 )),
        } )
      ]
      
      attr = AnnotationsAttribute.new( @java_class, 10, annotations )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "RuntimeVisibleAnnotations"
        assert_equals a.to_s, "@com.foo.Hoge(\n    aaa = \"aaa\",\n    bbb = 10\n)\n@com.foo.Var(\n    bbb = 10\n)"
        assert_equals a.annotations, annotations
        assert_equals a.dump, "000A0000 00190002 00300002 001E7300\n1E001F49 00330031 0001001F 490033"
        assert_equals a.to_bytes, [0x00, 0x0A, 0x00, 0x00, 0x00, 0x19, 0x00, 0x02, 0x00, 0x30, 0x00, 0x02, 0x00, 0x1E, 0x73, 0x00, 0x1E, 0x00, 0x1F, 0x49, 0x00, 0x33, 0x00, 0x31, 0x00, 0x01, 0x00, 0x1F, 0x49, 0x00, 0x33]
      }
      
      annotations = [
        Annotation.new( @java_class, 49, {
          "bbb"=> AnnotationElement.new( @java_class, 31, ConstAnnotationElementValue.new( @java_class, 'I'[0], 51 )),
        } )
      ]
      attr.annotations = annotations
      assert_attribute( attr ) {|a|
        assert_equals a.name, "RuntimeVisibleAnnotations"
        assert_equals a.to_s, "@com.foo.Var(\n    bbb = 10\n)"
        assert_equals a.annotations, annotations
        assert_equals a.dump, "000A0000 000B0001 00310001 001F4900\n33"
        assert_equals a.to_bytes, [0x00, 0x0A, 0x00, 0x00, 0x00, 0x0B, 0x00, 0x01, 0x00, 0x31, 0x00, 0x01, 0x00, 0x1F, 0x49, 0x00, 0x33]
      }
    end

    #
    #=== Annotationのテスト
    #
    def test_Annotation
      
      elements = {
        "aaa"=> AnnotationElement.new( @java_class, 30, ConstAnnotationElementValue.new( @java_class, 's'[0], 30 )),
        "bbb"=> AnnotationElement.new( @java_class, 31, ConstAnnotationElementValue.new( @java_class, 'I'[0], 51 )),
      }
      annotation = Annotation.new( @java_class, 48, elements )
      assert_annotation( annotation ) {|a|
        assert_equals a.to_s, "@com.foo.Hoge(\n    aaa = \"aaa\",\n    bbb = 10\n)"
        assert_equals a.type, "Lcom/foo/Hoge;"
        assert_equals a.type_index, 48
        assert_equals a.elements, elements
        assert_equals a.dump, "00300002 001E7300 1E001F49 0033"
        assert_equals a.to_bytes, [0x00, 0x30, 0x00, 0x02, 0x00, 0x1E, 0x73, 0x00, 0x1E, 0x00, 0x1F, 0x49, 0x00, 0x33]
      }
      elements = {
        "bbb"=> AnnotationElement.new( @java_class, 31, ConstAnnotationElementValue.new( @java_class, 'I'[0], 51 ))
      }
      annotation.type_index = 49
      annotation.elements = elements
      assert_annotation( annotation ) {|a|
        assert_equals a.to_s, "@com.foo.Var(\n    bbb = 10\n)"
        assert_equals a.type, "Lcom/foo/Var;"
        assert_equals a.type_index, 49
        assert_equals a.dump, "00310001 001F4900 33"
        assert_equals a.to_bytes, [0x00, 0x31, 0x00, 0x01, 0x00, 0x1F, 0x49, 0x00, 0x33]
      }
    end

    #
    #=== AnnotationElementのテスト
    #
    def test_AnnotationElement
      
      value = ConstAnnotationElementValue.new( @java_class, 's'[0], 30 )
      element = AnnotationElement.new( @java_class, 30, value )
      assert_annotation_element( element ) {|a|
        assert_equals a.to_s, "aaa = \"aaa\""
        assert_equals a.name, "aaa"
        assert_equals a.name_index, 30
        assert_equals a.value, value
        assert_equals a.dump, "001E7300 1E"
        assert_equals a.to_bytes, [0x00, 0x1E, 0x73, 0x00, 0x1E]
      }
      value = ConstAnnotationElementValue.new( @java_class, 's'[0], 31 )
      element.value = value
      element.name_index = 31
      assert_annotation_element( element ) {|a|
        assert_equals a.to_s, "bbb = \"bbb\""
        assert_equals a.name, "bbb"
        assert_equals a.name_index, 31
        assert_equals a.value, value
        assert_equals a.dump, "001F7300 1F"
        assert_equals a.to_bytes, [0x00, 0x1F, 0x73, 0x00, 0x1F]
      }
    end

    #
    #=== ArrayAnnotationElementValueのテスト
    #
    def test_ArrayAnnotationElementValue
      
      annotations = [
        ConstAnnotationElementValue.new( @java_class, 's'[0], 30 ),
        ConstAnnotationElementValue.new( @java_class, 's'[0], 31 )
      ]
      
      attr = ArrayAnnotationElementValue.new( @java_class, '['[0], annotations )
      assert_annotation_element_value( attr ) {|a|
        assert_equals a.to_s, "[\"aaa\",\"bbb\"]"
        assert_equals a.array, annotations
        assert_equals a.tag, '['[0]
        assert_equals a.dump, "5B000273 001E7300 1F"
        assert_equals a.to_bytes, [0x5B, 0x00, 0x02, 0x73, 0x00, 0x1E, 0x73, 0x00, 0x1F]
      }
      annotations = [
        ConstAnnotationElementValue.new( @java_class, 's'[0], 32 )
      ]
      attr.array = annotations
      assert_annotation_element_value( attr ) {|a|
        assert_equals a.to_s, "[\"ccc\"]"
        assert_equals a.array, annotations
        assert_equals a.tag, '['[0]
        assert_equals a.dump, "5B000173 0020"
        assert_equals a.to_bytes, [0x5B, 0x00, 0x01, 0x73, 0x00, 0x20]
      }
    end

    #
    #=== AnnotationAnnotationElementValueのテスト
    #
    def test_AnnotationAnnotationElementValue
      
      annotation = Annotation.new( @java_class, 48, {
        "aaa"=> AnnotationElement.new( @java_class, 30, ConstAnnotationElementValue.new( @java_class, 's'[0], 30 )),
        "bbb"=> AnnotationElement.new( @java_class, 31, ConstAnnotationElementValue.new( @java_class, 'I'[0], 51 )),
      } )
      attr = AnnotationAnnotationElementValue.new( @java_class, '@'[0], annotation )
      assert_annotation_element_value( attr ) {|a|
        assert_equals a.to_s, "@com.foo.Hoge(\n    aaa = \"aaa\",\n    bbb = 10\n)"
        assert_equals a.annotation, annotation
        assert_equals a.tag, '@'[0]
        assert_equals a.dump, "40003000 02001E73 001E001F 490033"
        assert_equals a.to_bytes, [0x40] + annotation.to_bytes
      }
      annotation = Annotation.new( @java_class, 49, {
        "bbb"=> AnnotationElement.new( @java_class, 31, ConstAnnotationElementValue.new( @java_class, 'I'[0], 51 )),
      } )
      attr.annotation = annotation
      assert_annotation_element_value( attr ) {|a|
        assert_equals a.to_s, "@com.foo.Var(\n    bbb = 10\n)"
        assert_equals a.annotation, annotation
        assert_equals a.tag, '@'[0]
        assert_equals a.dump, "40003100 01001F49 0033"
        assert_equals a.to_bytes, [0x40] + annotation.to_bytes
      }
    end

    #
    #=== ClassAnnotationElementValueのテスト
    #
    def test_ClassAnnotationElementValue
      
      attr = ClassAnnotationElementValue.new( @java_class, 'c'[0], 48 )
      assert_annotation_element_value( attr ) {|a|
        assert_equals a.to_s, "com.foo.Hoge.class"
        assert_equals a.class_info, "Lcom/foo/Hoge;"
        assert_equals a.class_info_index, 48
        assert_equals a.tag, 'c'[0]
        assert_equals a.dump, "630030"
        assert_equals a.to_bytes, [0x63, 0x00, 0x30]
      }
      attr.class_info_index = 49
      assert_annotation_element_value( attr ) {|a|
        assert_equals a.to_s, "com.foo.Var.class"
        assert_equals a.class_info, "Lcom/foo/Var;"
        assert_equals a.class_info_index, 49
        assert_equals a.tag, 'c'[0]
        assert_equals a.dump, "630031"
        assert_equals a.to_bytes, [0x63, 0x00, 0x31]
      }
    end

    #
    #=== EnumAnnotationElementValueのテスト
    #
    def test_EnumAnnotationElementValue
      
      attr = EnumAnnotationElementValue.new( @java_class, 'e'[0], 48, 46 )
      assert_annotation_element_value( attr ) {|a|
        assert_equals a.to_s, "com.foo.Hoge.FOO"
        assert_equals a.type_name, "Lcom/foo/Hoge;"
        assert_equals a.const_name, "FOO"
        assert_equals a.type_name_index, 48
        assert_equals a.const_name_index, 46
        assert_equals a.tag, 'e'[0]
        assert_equals a.dump, "65003000 2E"
        assert_equals a.to_bytes, [0x65, 0x00, 0x30, 0x00, 0x2E]
      }
      attr.type_name_index = 49
      attr.const_name_index = 47
      assert_annotation_element_value( attr ) {|a|
        assert_equals a.to_s, "com.foo.Var.VAR"
        assert_equals a.type_name, "Lcom/foo/Var;"
        assert_equals a.const_name, "VAR"
        assert_equals a.type_name_index, 49
        assert_equals a.const_name_index, 47
        assert_equals a.tag, 'e'[0]
        assert_equals a.dump, "65003100 2F"
        assert_equals a.to_bytes, [0x65, 0x00, 0x31, 0x00, 0x2F]
      }
    end

    #
    #=== ConstAnnotationElementValueのテスト
    #
    def test_ConstAnnotationElementValue
      
      attr = ConstAnnotationElementValue.new( @java_class, 's'[0], 30 )
      assert_annotation_element_value( attr ) {|a|
        assert_equals a.to_s, "\"aaa\""
        assert_equals a.value, "aaa"
        assert_equals a.const_value_index, 30
        assert_equals a.tag, 's'[0]
        assert_equals a.dump, "73001E"
        assert_equals a.to_bytes, [0x73, 0x00, 0x1E]
      }
      attr.tag = 'I'[0]
      attr.const_value_index = 51
      assert_annotation_element_value( attr ) {|a|
        assert_equals a.to_s, "10"
        assert_equals a.value, 10
        assert_equals a.const_value_index, 51
        assert_equals a.tag, 'I'[0]
        assert_equals a.dump, "490033"
        assert_equals a.to_bytes, [0x49, 0x00, 0x33]
      }
    end
    
    #
    #=== SignatureAttributeのテスト
    #
    def test_SignatureAttribute
      
      attr = SignatureAttribute.new( @java_class, 9, 40 )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "Signature"
        assert_equals a.to_s, "// signature com/foo/Hoge"
        assert_equals a.signature, "com/foo/Hoge"
        assert_equals a.signature_index, 40
        assert_equals a.dump, "00090000 00020028"
        assert_equals a.to_bytes, [0x00, 0x09, 0x00, 0x00, 0x00, 0x02, 0x00, 0x28]
      }
      attr.signature_index = 41
      assert_attribute( attr ) {|a|
        assert_equals a.name, "Signature"
        assert_equals a.to_s, "// signature com/foo/Var"
        assert_equals a.signature, "com/foo/Var"
        assert_equals a.signature_index, 41
        assert_equals a.dump, "00090000 00020029"
        assert_equals a.to_bytes, [0x00, 0x09, 0x00, 0x00, 0x00, 0x02, 0x00, 0x29]
      }
    end
    
    #
    #=== SignatureAttributeのテスト
    #
    def test_SignatureAttribute
      
      attr = SignatureAttribute.new( @java_class, 9, 40 )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "Signature"
        assert_equals a.to_s, "// signature com/foo/Hoge"
        assert_equals a.signature, "com/foo/Hoge"
        assert_equals a.signature_index, 40
        assert_equals a.dump, "00090000 00020028"
        assert_equals a.to_bytes, [0x00, 0x09, 0x00, 0x00, 0x00, 0x02, 0x00, 0x28]
      }
      attr.signature_index = 41
      assert_attribute( attr ) {|a|
        assert_equals a.name, "Signature"
        assert_equals a.to_s, "// signature com/foo/Var"
        assert_equals a.signature, "com/foo/Var"
        assert_equals a.signature_index, 41
        assert_equals a.dump, "00090000 00020029"
        assert_equals a.to_bytes, [0x00, 0x09, 0x00, 0x00, 0x00, 0x02, 0x00, 0x29]
      }
    end
    
    #
    #=== SourceFileAttributeのテスト
    #
    def test_SourceFileAttribute
      
      attr = SourceFileAttribute.new( @java_class, 7, 30 )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "SourceFile"
        assert_equals a.to_s, "// source aaa"
        assert_equals a.source_file, "aaa"
        assert_equals a.source_file_index, 30
        assert_equals a.dump, "00070000 0002001E"
        assert_equals a.to_bytes, [0x00, 0x07, 0x00, 0x00, 0x00, 0x02, 0x00, 0x1E]
      }
      attr.source_file_index = 31
      assert_attribute( attr ) {|a|
        assert_equals a.name, "SourceFile"
        assert_equals a.to_s, "// source bbb"
        assert_equals a.source_file, "bbb"
        assert_equals a.source_file_index, 31
        assert_equals a.dump, "00070000 0002001F"
        assert_equals a.to_bytes, [0x00, 0x07, 0x00, 0x00, 0x00, 0x02, 0x00, 0x1F]
      }
    end
    
    #
    #=== SyntheticAttributeのテスト
    #
    def test_SyntheticAttribute
      
      attr = SyntheticAttribute.new( @java_class, 6 )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "Synthetic"
        assert_equals a.dump, "00060000 0000"
        assert_equals a.to_bytes, [0x00, 0x06, 0x00, 0x00, 0x00, 0x00]
      }
      
    end
    
    #
    #=== DeprecatedAttributeのテスト
    #
    def test_DeprecatedAttribute
      
      attr = DeprecatedAttribute.new( @java_class, 5 )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "Deprecated"
        assert_equals a.to_s, "// !!Deprecated!!"
        assert_equals a.dump, "00050000 0000"
        assert_equals a.to_bytes, [0x00, 0x05, 0x00, 0x00, 0x00, 0x00]
      }
      
    end
    
    #
    #=== EnclosingMethodAttributeのテスト
    #
    def test_EnclosingMethodAttribute
      
      attr = EnclosingMethodAttribute.new( @java_class, 4, 100, 120 )
      assert_attribute( attr ) {|a|
        assert_equals a.name, "EnclosingMethod"
        assert_equals a.to_s, "// enclosed by com.foo.Hoge#aaa"
        assert_equals a.enclosing_class, @java_class.constant_pool[100]
        assert_equals a.enclosing_method, @java_class.constant_pool[120]
        assert_equals a.enclosing_class_index, 100
        assert_equals a.enclosing_method_index, 120
        assert_equals a.dump, "00040000 00040064 0078"
        assert_equals a.to_bytes, [0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x00, 0x64, 0x00, 0x78]
      }
      attr.enclosing_class_index = 101
      attr.enclosing_method_index = 121
      assert_attribute( attr ) {|a|
        assert_equals a.name, "EnclosingMethod"
        assert_equals a.to_s, "// enclosed by com.foo.Var#bbb"
        assert_equals a.enclosing_class, @java_class.constant_pool[101]
        assert_equals a.enclosing_method, @java_class.constant_pool[121]
        assert_equals a.enclosing_class_index, 101
        assert_equals a.enclosing_method_index, 121
        assert_equals a.dump, "00040000 00040065 0079"
        assert_equals a.to_bytes, [0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x00, 0x65, 0x00, 0x79]
      }
    end
    
    #
    #=== ConstantValueAttributesのテスト
    #
    def test_ConstantValueAttributes
      
      attr = ConstantValueAttribute.new( @java_class, 1, 30)
      assert_attribute( attr ) {|a|
        assert_equals a.to_s, "\"aaa\""
        assert_equals a.value, "aaa"
        assert_equals a.name, "ConstantValue"
        assert_equals a.constant_value_index, 30
        assert_equals a.dump, "00010000 0002001E"
        assert_equals a.to_bytes, [0x00, 0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x1E]
      }

      attr.constant_value_index = 50
      assert_attribute( attr ) {|a|
        assert_equals a.to_s, "0"
        assert_equals a.value, 0
        assert_equals a.name, "ConstantValue"
        assert_equals a.constant_value_index, 50
        assert_equals a.dump, "00010000 00020032"
        assert_equals a.to_bytes, [0x00, 0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x32]
      }
    end

    #
    #=== ExceptionsAttributesのテスト
    #
    def test_ExceptionsAttributes
      attr = ExceptionsAttribute.new( @java_class, 2, [103,104])
      assert_attribute( attr ) {|a|
        assert_equals a.name, "Exceptions"
        assert_equals a.to_s, "throws java.lang.Exception, java.lang.Throwable"
        assert_equals a.exception_index_table, [103,104]
        assert_equals a.exceptions, [@java_class.constant_pool[103],@java_class.constant_pool[104]]
        assert_equals a.dump, "00020000 00060002 00670068"
        assert_equals a.to_bytes, [0x00, 0x02, 0x00, 0x00, 0x00, 0x06, 0x00, 0x02, 0x00, 0x67, 0x00, 0x68]
      }
      
      attr.exception_index_table = [105]
      assert_attribute( attr ) {|a|
        assert_equals a.name, "Exceptions"
        assert_equals a.to_s, "throws com.foo.HogeException"
        assert_equals a.exception_index_table, [105]
        assert_equals a.exceptions, [@java_class.constant_pool[105]]
        assert_equals a.dump, "00020000 00040001 0069"
        assert_equals a.to_bytes, [0x00, 0x02, 0x00, 0x00, 0x00, 0x04, 0x00, 0x01, 0x00, 0x69]
      }
    end
    
    
    #
    #=== InnerClassesAttributesのテスト
    #
    def test_InnerClassesAttributes
      
      access_flag = JavaClass::InnerClassAccessFlag.new( 0x0001 )
      classes = [
        InnerClass.new( @java_class, 100, 101, 30, access_flag),
        InnerClass.new( @java_class, 101, 102, 31, access_flag)
      ]
      attr = InnerClassesAttribute.new( @java_class, 3, classes )
      assert_attribute( attr ) {|a|
        assert_equals a.to_s, "// use inner public class com.foo.Hoge\n// use inner public class com.foo.Var"
        assert_equals a.classes, classes
        assert_equals a.name, "InnerClasses"
        assert_equals a.dump, "00030000 00120002 " \
          << classes[0].dump << "\n" << classes[1].dump
        assert_equals a.to_bytes, [0x00, 0x03, 0x00, 0x00, 0x00, 0x12, 0x00, 0x02 ] \
          + classes[0].to_bytes + classes[1].to_bytes
      }
      
      classes = [InnerClass.new( @java_class, 102, 102, 32, access_flag)]
      attr.classes = classes
      assert_attribute( attr ) {|a|
        assert_equals a.to_s, "// use inner public class com.foo.Piyo"
        assert_equals a.classes, classes
        assert_equals a.name, "InnerClasses"
        assert_equals a.dump, "00030000 000A0001 " << classes[0].dump
        assert_equals a.to_bytes, [0x00, 0x03, 0x00, 0x00, 0x00, 0x0A, 0x00, 0x01 ] + classes[0].to_bytes
      }
    end
    
    #
    #=== InnerClassのテスト
    #
    def test_InnerClass
      access_flag = JavaClass::InnerClassAccessFlag.new( 0x0001 )
      inner_class = InnerClass.new( @java_class, 100, 101, 30, access_flag)
      assert_inner_class( inner_class ) {|a|
        assert_equals a.to_s, "// use inner public class com.foo.Hoge"
        assert_equals a.inner_class, @java_class.constant_pool[100]
        assert_equals a.outer_class, @java_class.constant_pool[101]
        assert_equals a.name, "aaa"
        assert_equals a.inner_class_index, 100
        assert_equals a.outer_class_index, 101
        assert_equals a.name_index, 30
        assert_equals a.access_flag, access_flag
        assert_equals a.dump, "00640065 001E0001"
        assert_equals a.to_bytes, [0x00, 0x64, 0x00, 0x65, 0x00, 0x1E, 0x00, 0x01]
      }

      inner_class.inner_class_index = 102
      inner_class.name_index = 31
      inner_class.access_flag.on( JavaClass::InnerClassAccessFlag::ACC_INTERFACE )
      assert_inner_class( inner_class) {|a|
        assert_equals a.to_s, "// use inner public interface com.foo.Piyo"
        assert_equals a.inner_class, @java_class.constant_pool[102]
        assert_equals a.outer_class, @java_class.constant_pool[101]
        assert_equals a.name, "bbb"
        assert_equals a.inner_class_index, 102
        assert_equals a.outer_class_index, 101
        assert_equals a.name_index, 31
        assert_equals a.access_flag, access_flag
        assert_equals a.dump, "00660065 001F0201"
        assert_equals a.to_bytes, [0x00, 0x66, 0x00, 0x65, 0x00, 0x1F, 0x02, 0x01]
      }
    end
    
    def assert_attribute( a, &block )
      assert_to_byte_and_read a, block, proc {|io|  
        JavaClass.read_attribute( io, @java_class )
      }
    end

    def assert_inner_class( a, &block )
      assert_to_byte_and_read a, block, proc {|io|  
        JavaClass.read_inner_class( io, @java_class )
      }
    end

    def assert_annotation_element_value( a, &block )
      assert_to_byte_and_read a, block, proc {|io|  
        JavaClass.read_annotation_element_value( io, @java_class )
      }
    end

    def assert_annotation_element( a, &block )
      assert_to_byte_and_read a, block, proc {|io|  
        JavaClass.read_annotation_element( io, @java_class )
      }
    end

    def assert_annotation( a, &block )
      assert_to_byte_and_read a, block, proc {|io|  
        JavaClass.read_annotation( io, @java_class )
      }
    end

    def assert_exception( a, &block )
      assert_to_byte_and_read a, block, proc {|io|  
        JavaClass.read_exception( io, @java_class )
      }
    end

    def assert_line_number( a, &block )
      assert_to_byte_and_read a, block, proc {|io|  
        JavaClass.read_line_number( io, @java_class )
      }
    end
    
    def assert_local_variable( a, &block )
      assert_to_byte_and_read a, block, proc {|io|  
        JavaClass.read_local_variable( io, @java_class )
      }
    end
    
    def assert_local_variable_type( a, &block )
      assert_to_byte_and_read a, block, proc {|io|  
        JavaClass.read_local_variable_type( io, @java_class )
      }
    end
  end

end
