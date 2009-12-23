#!/usr/bin/ruby

$: << "../lib"

require "test/unit"

require "javaclass"
require "test_util"

module JavaClass
  
  
  #
  #===Memberのテスト
  #
  class MemberTest < Test::Unit::TestCase
    
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
      @java_class.constant_pool[17]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "RuntimeInvisibleAnnotations" )
      @java_class.constant_pool[18]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "RuntimeVisibleParameterAnnotations" )

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

      @java_class.constant_pool[60] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "(B[ILcom/foo/Var;)Lcom/foo/Hoge;" )
      @java_class.constant_pool[61] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "()[Lcom/foo/Hoge;" )
      @java_class.constant_pool[71] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "()[Lcom/foo/Hoge;" )
      
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
      f.access_flag = FieldAccessFlag.new( FieldAccessFlag::ACC_PUBLIC | FieldAccessFlag::ACC_STATIC )
      f.name_index = 30
      f.descriptor_index = 48
      f.attributes = {
        "Deprecated"=>DeprecatedAttribute.new( @java_class, 5 ),
        "ConstantValue"=>ConstantValueAttribute.new( @java_class, 1, 51),
        "RuntimeVisibleAnnotations"=>AnnotationsAttribute.new( @java_class, 10, [
          Annotation.new( @java_class, 48 )
        ]),
        "RuntimeInvisibleAnnotations"=>AnnotationsAttribute.new( @java_class, 17, [
          Annotation.new( @java_class, 49 )
        ])
      }
      assert_field( f ) {|a|
        assert_equal a.name, "aaa"
        assert_equal a.descriptor, "Lcom/foo/Hoge;"
        assert_equal a.static_value, 10
        assert_equal a.signature, nil
        assert_equal a.deprecated?, true
        assert_equal a.annotations, [Annotation.new( @java_class, 48 ), Annotation.new( @java_class, 49 )]
        assert_equal a.to_s, <<-STR.chomp!
// !deprecated!
@com.foo.Hoge
@com.foo.Var
public static com.foo.Hoge aaa = 10
STR
        assert_equal a.dump, 
          "0009001E 00300004 00010000 00020033\n" +
          "00050000 00000011 00000006 00010031\n" + 
          "0000000A 00000006 00010030 0000"
        assert_equal a.to_bytes, [
         0x00, 0x09, 0x00, 0x1E, 0x00, 0x30, 0x00, 0x04, 
         0x00, 0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x33, 
         0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 
         0x00, 0x00, 0x00, 0x06, 0x00, 0x01, 0x00, 0x31, 
         0x00, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 
         0x00, 0x01, 0x00, 0x30, 0x00, 0x00 ]
      }


      f.access_flag.on( FieldAccessFlag::ACC_FINAL ).off( FieldAccessFlag::ACC_STATIC )
      f.name_index = 31
      f.descriptor_index = 49
      f.attributes = {
        "Signature"=>SignatureAttribute.new( @java_class, 9, 41 ),
        "RuntimeInvisibleAnnotations"=>AnnotationsAttribute.new( @java_class, 17, [
          Annotation.new( @java_class, 49 )
        ])
      }
      assert_field( f ) {|a|
        assert_equal a.name, "bbb"
        assert_equal a.descriptor, "Lcom/foo/Var;"
        assert_equal a.static_value, nil
        assert_equal a.signature, "com/foo/Var"
        assert_equal a.deprecated?, false
        assert_equal a.annotations, [Annotation.new( @java_class, 49 )]
        assert_equal a.to_s, <<-STR.chomp!
// signature com/foo/Var
@com.foo.Var
public final com.foo.Var bbb
STR
        assert_equal a.dump, 
          "0011001F 00310002 00110000 00060001\n"+ 
          "00310000 00090000 00020029"
        assert_equal a.to_bytes, [
         0x00, 0x11, 0x00, 0x1F, 0x00, 0x31, 0x00, 0x02, 
         0x00, 0x11, 0x00, 0x00, 0x00, 0x06, 0x00, 0x01, 
         0x00, 0x31, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 
         0x00, 0x02, 0x00, 0x29 ]
      }
    end
    
        
    #
    #=== Methodのテスト
    #
    def test_Method
      
      m = Method.new( @java_class )
      m.access_flag = MethodAccessFlag.new( MethodAccessFlag::ACC_PUBLIC | MethodAccessFlag::ACC_STATIC )
      m.name_index = 30
      m.descriptor_index = 60
      m.attributes = {
        "Deprecated"=>DeprecatedAttribute.new( @java_class, 5 ),
        "Exceptions"=>ExceptionsAttribute.new( @java_class, 2, [103,104]),
        "RuntimeVisibleAnnotations"=>AnnotationsAttribute.new( @java_class, 10, [
          Annotation.new( @java_class, 48 )
        ]),
        "RuntimeInvisibleAnnotations"=>AnnotationsAttribute.new( @java_class, 17, [
          Annotation.new( @java_class, 49 )
        ]),
        "RuntimeVisibleParameterAnnotations"=>ParameterAnnotationsAttribute.new( @java_class, 18, [
          [Annotation.new( @java_class, 49 )], 
          [], 
          [Annotation.new( @java_class, 48 )]
        ]),
        "RuntimeInvisibleParameterAnnotations"=>ParameterAnnotationsAttribute.new( @java_class, 11, [
          [Annotation.new( @java_class, 48 )], 
          [], 
          []
        ]),
        "Code"=> CodeAttribute.new( @java_class, 13, 10, 8, [Code.new(@java_class, 0, 0x05), Code.new(@java_class, 1, 0x06)], [], {} )
      }
      assert_method( m ) {|a|
        assert_equal a.name, "aaa"
        assert_equal a.descriptor, "(B[ILcom/foo/Var;)Lcom/foo/Hoge;"
        assert_equal a.parameters, ["byte", "int[]", "com.foo.Var"]
        assert_equal a.return_type, "com.foo.Hoge"
        assert_equal a.exceptions, ["java.lang.Exception", "java.lang.Throwable"]
        assert_equal a.signature, nil
        assert_equal a.deprecated?, true
        assert_equal a.annotations, [Annotation.new( @java_class, 48 ), Annotation.new( @java_class, 49 )]
        assert_equal a.parameter_annotations(0), [Annotation.new( @java_class, 49 ), Annotation.new( @java_class, 48 )]
        assert_equal a.parameter_annotations(1), []
        assert_equal a.parameter_annotations(2), [Annotation.new( @java_class, 48 )]
        assert_equal a.to_s, <<-STR.chomp!
// !deprecated!
@com.foo.Hoge
@com.foo.Var
public static com.foo.Hoge aaa ( @com.foo.Var
@com.foo.Hoge byte arg1, int[] arg2, @com.foo.Hoge com.foo.Var arg3 )
throws java.lang.Exception, java.lang.Throwable {

    0 : iconst_2
    1 : iconst_3
}
STR
        assert_equal a.dump, 
          "0009001E 003C0007 000D0000 000E000A\n" +
          "00080000 00020506 00000000 00050000\n" +
          "00000002 00000006 00020067 00680011\n" +
          "00000006 00010031 0000000B 0000000B\n" + 
          "03000100 30000000 00000000 0A000000\n" +
          "06000100 30000000 12000000 0F030001\n" +
          "00310000 00000001 00300000"
        assert_equal a.to_bytes, [
         0x00, 0x09, 0x00, 0x1E, 0x00, 0x3C, 0x00, 0x07, 
         0x00, 0x0D, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x0A, 
         0x00, 0x08, 0x00, 0x00, 0x00, 0x02, 0x05, 0x06,
         0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00,
         0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x06, 
         0x00, 0x02, 0x00, 0x67, 0x00, 0x68, 0x00, 0x11, 
         0x00, 0x00, 0x00, 0x06, 0x00, 0x01, 0x00, 0x31, 
         0x00, 0x00, 0x00, 0x0B, 0x00, 0x00, 0x00, 0x0B, 
         0x03, 0x00, 0x01, 0x00, 0x30, 0x00, 0x00, 0x00, 
         0x00, 0x00, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 
         0x06, 0x00, 0x01, 0x00, 0x30, 0x00, 0x00, 0x00,
         0x12, 0x00, 0x00, 0x00, 0x0F, 0x03, 0x00, 0x01,
         0x00, 0x31, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
         0x00, 0x30, 0x00, 0x00 ]
      }
      
      m.access_flag.on( MethodAccessFlag::ACC_PRIVATE ).off( MethodAccessFlag::ACC_STATIC ).off( MethodAccessFlag::ACC_PUBLIC )
      m.name_index = 31
      m.descriptor_index = 61
      m.attributes = {
        "Signature"=>SignatureAttribute.new( @java_class, 9, 71 ),
        "RuntimeVisibleAnnotations"=>AnnotationsAttribute.new( @java_class, 10, [
          Annotation.new( @java_class, 49 )
        ])
      }
      assert_method( m ) {|a|
        assert_equal a.name, "bbb"
        assert_equal a.descriptor, "()[Lcom/foo/Hoge;"
        assert_equal a.parameters, []
        assert_equal a.return_type, "com.foo.Hoge[]"
        assert_equal a.exceptions, []
        assert_equal a.signature, "()[Lcom/foo/Hoge;"
        assert_equal a.deprecated?, false
        assert_equal a.annotations, [Annotation.new( @java_class, 49 )]
        assert_equal a.parameter_annotations(0), []
        assert_equal a.to_s, <<-STR.chomp!
// signature ()[Lcom/foo/Hoge;
@com.foo.Var
private com.foo.Hoge[] bbb (  )
STR
        assert_equal a.dump, 
          "0002001F 003D0002 000A0000 00060001\n"+ 
          "00310000 00090000 00020047"
        assert_equal a.to_bytes, [
         0x00, 0x02, 0x00, 0x1F, 0x00, 0x3D, 0x00, 0x02, 
         0x00, 0x0A, 0x00, 0x00, 0x00, 0x06, 0x00, 0x01,
         0x00, 0x31, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00,
         0x00, 0x02, 0x00, 0x47]
      }
    end
    
    def assert_field( field, &block )
      assert_to_byte_and_read field, block, proc {|io|  
        JavaClass.read_field( io, @java_class )
      }
    end
    
    def assert_method( field, &block )
      assert_to_byte_and_read field, block, proc {|io|  
        JavaClass.read_method( io, @java_class )
      }
    end
  end

end
