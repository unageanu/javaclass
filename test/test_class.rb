#!/usr/bin/ruby

$: << "../lib"

require "test/unit"
require "javaclass"
require "test_util"

require "javaclass"

module JavaClass
  
  #
  #=== Classのテスト
  #
  class ClassTest < Test::Unit::TestCase
    
    include TestUtil
    
    def setup
    end
  
    def teardown
    end
    
    #
    #=== 基本のクラスの解析テスト
    #
    def test_Basic
    
      jc = get_class_from_resource( "/java_class/com/example/TestClass1.class")
      assert_class( jc ) {|a|
        assert_equal a.name, "com.example.TestClass1"
        assert_equal a.super_class, "java.util.ArrayList"
        assert_equal a.interfaces, ["java.io.Serializable", "java.io.Closeable"]
        assert_equal a.signature, "<T:Ljava/lang/Object;X::Ljava/lang/Runnable;>Ljava/util/ArrayList<TT;>;Ljava/io/Serializable;Ljava/io/Closeable;"
        assert_equal a.deprecated?, false
        assert_equal a.source_file, "TestClass1.java"
        assert_equal a.inner_classes.map{|c| "#{c.name}:#{c.inner_class.name}" }, 
          [ ":com.example.TestClass1$1", "Hoo:com.example.TestClass1$Hoo", "Var:com.example.TestClass1$Var" ]
        assert_equal a.enclosing_method, nil
        assert_equal a.access_flag, ClassAccessFlag.new( 
          ClassAccessFlag::ACC_PUBLIC | ClassAccessFlag::ACC_FINAL | ClassAccessFlag::ACC_SUPER )
        assert_equal a.fields.length, 10
        assert_equal a.methods.length, 3
        
        assert_equal a.find_method( "close" ).name, "close"
        assert_equal a.find_method( "not found" ), nil
        assert_equal a.find_method( "close", "void" ).name, "close"
        assert_equal a.find_method( "close", "not"  ), nil
        assert_equal a.find_method( "close", "void", [] ).name, "close"
        assert_equal a.find_method( "close", "void", ["not"]  ), nil
        
        assert_equal a.find_field( "stringConstant" ).name, "stringConstant"
        assert_equal a.find_field( "not found" ), nil
      }
      
      jc = get_class_from_resource( "/java_class/com/example/TestClass1.class")
      jc.put_constant( UTF8Constant.new( nil, Constant::CONSTANT_Utf8, "abc" ) )
      assert_class( jc ) {|a|
      
      }
      
    end
    
    def get_class_from_resource( path )
      File.open( resource( path), "r" ) {|f|
        JavaClass.from f
      }
    end
    
    def assert_class( a, &block )
      assert_to_byte_and_read a, block, proc {|io|  
        JavaClass.from( io )
      }
    end
  end

end
