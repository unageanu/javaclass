#!/usr/bin/ruby

$: << "../src"

require "runit/testcase"
require "runit/cui/testrunner"

require "javaclass"
require "test-util"

module JavaClass
  
  #
  #===Memberのテスト
  #
  class MemberTest <  RUNIT::TestCase
    
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
    #=== Fieldのテスト
    #
    def test_Field
      
      f = Field.new( @java_class )
      f.access_flag = FieldAccessFlag.new( FieldAccessFlag::ACC_PUBLIC )
      f.name_index = 30
      f.descriptor_index = 40
      f.attributes = {
        ""=>,
        ""=>
      }
      
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
    
    def assert_field( field, &block )
      assert_to_byte_and_read field, block, proc {|io|  
        JavaClass.read_field( io, @java_class )
      }
    end
  end

end
