#!/usr/bin/ruby

$: << "../src"

require "runit/testcase"
require "runit/cui/testrunner"

require "javaclass"
require "test-util"

module JavaClass

	#
	#===UTF8Constantのテスト
	#
	class UTF8ConstantTest <  RUNIT::TestCase
	
	  def setup
	    @java_class = JavaClass::Class.new
	  end
	
	  def teardown
	  end
	  
    #
    #=== 基本動作のテスト
    #
	  def test_basic
	     
	    c = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "abc" )
      assert_equals( c.bytes, "abc" )
      assert_equals( c.to_s,  "\"abc\"" )
      assert_equals( c.to_bytes, [0x01, 0x00, 0x03, 0x61, 0x62, 0x63] )
      assert_equals( c.dump, "01000361 6263" )
      
      # バイト配列に変換して再構築
      c2 = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c2.bytes, "abc" )
      assert_equals( c2.to_s,  "\"abc\"" )
      assert_equals( c2.to_bytes, [0x01, 0x00, 0x03, 0x61, 0x62, 0x63] )
      assert_equals( c2.dump, "01000361 6263" )    
      
      c.bytes = "bbbbb"
      assert_equals( c.bytes, "bbbbb" )
      assert_equals( c.to_s,  "\"bbbbb\"" )
      assert_equals( c.to_bytes, [0x01, 0x00, 0x05, 0x62, 0x62, 0x62, 0x62, 0x62] )
      assert_equals( c.dump, "01000562 62626262" )
      
      # 日本語を含む
      c.bytes = "あいう"
      assert_equals( c.bytes, "あいう" )
      assert_equals( c.to_s,  "\"あいう\"" )
      assert_equals( c.to_bytes, [0x01, 0x00, 0x09, 0xe3, 0x81, 0x82, 0xe3, 0x81, 0x84, 0xe3, 0x81, 0x86] )
      assert_equals( c.dump, "010009E3 8182E381 84E38186" )      
      
      c2 = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c2.bytes, "あいう" )
      assert_equals( c2.to_s,  "\"あいう\"" )
      assert_equals( c2.to_bytes, [0x01, 0x00, 0x09, 0xe3, 0x81, 0x82, 0xe3, 0x81, 0x84, 0xe3, 0x81, 0x86] )
      assert_equals( c2.dump, "010009E3 8182E381 84E38186" )
      
	  end
	  
    #
    #=== equalsのテスト。
    #
    def test_equals()
      c  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "abc" )
      c2 = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "abb" )
      c3 = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      c4 = UTF8Constant.new( @java_class, Constant::CONSTANT_Class, "abc" )
      
      assert_not_equal( c, c2 )
      assert_equal( c, c3 )
      assert_not_equal( c2, c3 )
      assert_not_equal( c, c4 )
    end
    
	end

  #
  #==IntegerConstantのテスト
  #
  class IntegerConstantTest <  RUNIT::TestCase
  
    def setup
      @java_class = JavaClass::Class.new
    end
  
    def teardown
    end
    
    #
    #=== 基本動作のテスト
    #
    def test_basic
      
      # 正の整数
      c = IntegerConstant.new( @java_class, Constant::CONSTANT_Integer, 100 )
      assert_equals( c.bytes, 100 )
      assert_equals( c.to_s,  "100" )
      assert_equals( c.to_bytes, [0x03, 0x00, 0x00, 0x00, 0x64] )
      assert_equals( c.dump, "03000000 64" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.bytes, 100 )
      assert_equals( c.to_s,  "100" )
      assert_equals( c.to_bytes, [0x03, 0x00, 0x00, 0x00, 0x64] )
      assert_equals( c.dump, "03000000 64" )
      
      # 負の整数
      c.bytes = -100
      assert_equals( c.bytes, -100 )
      assert_equals( c.to_s,  "-100" )
      assert_equals( c.to_bytes, [0x03, 0xFF, 0xFF, 0xFF, 0x9C] )
      assert_equals( c.dump, "03FFFFFF 9C" )

      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.bytes, -100 )
      assert_equals( c.to_s,  "-100" )
      assert_equals( c.to_bytes, [0x03, 0xFF, 0xFF, 0xFF, 0x9C] )
      assert_equals( c.dump, "03FFFFFF 9C" )
      
      # 最大値
      c.bytes = 2147483647
      assert_equals( c.bytes, 2147483647 )
      assert_equals( c.to_s,  "2147483647" )
      assert_equals( c.to_bytes, [0x03, 0x7F, 0xFF, 0xFF, 0xFF] )
      assert_equals( c.dump, "037FFFFF FF" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes, 2147483647 )
      assert_equals( c.to_s,  "2147483647" )
      assert_equals( c.to_bytes, [0x03, 0x7F, 0xFF, 0xFF, 0xFF] )
      assert_equals( c.dump, "037FFFFF FF" )   
            
      # 最小値
      c.bytes = -2147483648
      assert_equals( c.bytes, -2147483648 )
      assert_equals( c.to_s,  "-2147483648" )
      assert_equals( c.to_bytes, [0x03, 0x80, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "03800000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes, -2147483648 )
      assert_equals( c.to_s,  "-2147483648" )
      assert_equals( c.to_bytes, [0x03, 0x80, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "03800000 00" )       
      
      # 0
      c.bytes = 0
      assert_equals( c.bytes, 0 )
      assert_equals( c.to_s,  "0" )
      assert_equals( c.to_bytes, [0x03, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "03000000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes, 0 )
      assert_equals( c.to_s,  "0" )
      assert_equals( c.to_bytes, [0x03, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "03000000 00" )      
      
    end
    
    #
    #=== 閾値チェックのテスト
    #
    def test_range_error
      [2147483648, -2147483649].each {|i|
        JavaClass::assert_range_error {
          c = IntegerConstant.new( @java_class, Constant::CONSTANT_Integer, 0 )
          c.bytes = i
        }        
      }      
    end
    
  end
  
  #
  #==LongConstantのテスト
  #
  class LongConstantTest <  RUNIT::TestCase
  
    def setup
      @java_class = JavaClass::Class.new
    end
  
    def teardown
    end
    
    #
    #=== 基本動作のテスト
    #
    def test_basic
      
      # 正の整数
      c = LongConstant.new( @java_class, Constant::CONSTANT_Long, 100 )
      assert_equals( c.bytes, 100 )
      assert_equals( c.to_s,  "100L" )
      assert_equals( c.to_bytes, [0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x64] )
      assert_equals( c.dump, "05000000 00000000 64" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.bytes, 100 )
      assert_equals( c.to_s,  "100L" )
      assert_equals( c.to_bytes, [0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x64] )
      assert_equals( c.dump, "05000000 00000000 64" )
      
      # 負の整数
      c.bytes = -100
      assert_equals( c.bytes, -100 )
      assert_equals( c.to_s,  "-100L" )
      assert_equals( c.to_bytes, [0x05, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x9C] )
      assert_equals( c.dump, "05FFFFFF FFFFFFFF 9C" )

      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.bytes, -100 )
      assert_equals( c.to_s,  "-100L" )
      assert_equals( c.to_bytes, [0x05, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x9C] )
      assert_equals( c.dump, "05FFFFFF FFFFFFFF 9C" )
      
      # 最大値
      c.bytes = 9223372036854775807
      assert_equals( c.bytes, 9223372036854775807 )
      assert_equals( c.to_s,  "9223372036854775807L" )
      assert_equals( c.to_bytes, [0x05, 0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF] )
      assert_equals( c.dump, "057FFFFF FFFFFFFF FF" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes, 9223372036854775807 )
      assert_equals( c.to_s,  "9223372036854775807L" )
      assert_equals( c.to_bytes, [0x05, 0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF] )
      assert_equals( c.dump, "057FFFFF FFFFFFFF FF" )
            
      # 最小値
      c.bytes = -9223372036854775808
      assert_equals( c.bytes, -9223372036854775808 )
      assert_equals( c.to_s,  "-9223372036854775808L" )
      assert_equals( c.to_bytes, [0x05, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "05800000 00000000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes, -9223372036854775808 )
      assert_equals( c.to_s,  "-9223372036854775808L" )
      assert_equals( c.to_bytes, [0x05, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "05800000 00000000 00" )      
      
      # 0
      c.bytes = 0
      assert_equals( c.bytes, 0 )
      assert_equals( c.to_s,  "0L" )
      assert_equals( c.to_bytes, [0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "05000000 00000000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes, 0 )
      assert_equals( c.to_s,  "0L" )
      assert_equals( c.to_bytes, [0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "05000000 00000000 00" )   
      
    end
    
    #
    #=== 閾値チェックのテスト
    #
    def test_range_error
      [9223372036854775808, -9223372036854775809].each {|i|
        JavaClass::assert_range_error {
          c = LongConstant.new( @java_class, Constant::CONSTANT_Long, 0 )
          c.bytes = i
        }        
      }      
    end
    
  end

  #
  #==FloatConstantのテスト
  #
  class FloatConstantTest <  RUNIT::TestCase
  
    def setup
      @java_class = JavaClass::Class.new
    end
  
    def teardown
    end
    
    #
    #=== 基本動作のテスト
    #
    def test_basic
      
      # 正の数
      c = FloatConstant.new( @java_class, Constant::CONSTANT_Float, 0x41840000 )
      assert_equals( c.bytes.to_s, "16.5" )
      assert_equals( c.to_s,  "16.5F" )
      assert_equals( c.to_bytes, [0x04, 0x41, 0x84, 0x00, 0x00] )
      assert_equals( c.dump, "04418400 00" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.bytes.to_s, "16.5" )
      assert_equals( c.to_s,  "16.5F" )
      assert_equals( c.to_bytes, [0x04, 0x41, 0x84, 0x00, 0x00] )
      assert_equals( c.dump, "04418400 00" )
      
      # 負の数
      c = FloatConstant.new( @java_class, Constant::CONSTANT_Float, 0xC1840000 )
      assert_equals( c.bytes.to_s, "-16.5" )
      assert_equals( c.to_s,  "-16.5F" )
      assert_equals( c.to_bytes, [0x04, 0xC1, 0x84, 0x00, 0x00] )
      assert_equals( c.dump, "04C18400 00" )

      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.bytes.to_s, "-16.5" )
      assert_equals( c.to_s,  "-16.5F" )
      assert_equals( c.to_bytes, [0x04, 0xC1, 0x84, 0x00, 0x00] )
      assert_equals( c.dump, "04C18400 00" )
      
      # 0
      c = FloatConstant.new( @java_class, Constant::CONSTANT_Float, 0x00000000 )
      assert_equals( c.bytes.to_s, "0.0" )
      assert_equals( c.to_s,  "0.0F" )
      assert_equals( c.to_bytes, [0x04, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "04000000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes.to_s, "0.0" )
      assert_equals( c.to_s,  "0.0F" )
      assert_equals( c.to_bytes, [0x04, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "04000000 00" )   
      
      # NaN
      c = FloatConstant.new( @java_class, Constant::CONSTANT_Float, 0x7FC00000 )
      assert_equals( c.bytes.to_s, "NaN" )
      assert_equals( c.to_s,  "NaN" )
      assert_equals( c.to_bytes, [0x04, 0x7F, 0xC0, 0x00, 0x00] )
      assert_equals( c.dump, "047FC000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes.to_s, "NaN" )
      assert_equals( c.to_s,  "NaN" )
      assert_equals( c.to_bytes, [0x04, 0x7F, 0xC0, 0x00, 0x00] )
      assert_equals( c.dump, "047FC000 00" )  
      
      # Infinity
      c = FloatConstant.new( @java_class, Constant::CONSTANT_Float, 0x7F800000 )
      assert_equals( c.bytes.to_s,  "Infinity" )
      assert_equals( c.to_s,  "Infinity" )
      assert_equals( c.to_bytes, [0x04, 0x7F, 0x80, 0x00, 0x00] )
      assert_equals( c.dump, "047F8000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes.to_s,  "Infinity" )
      assert_equals( c.to_s,  "Infinity" )
      assert_equals( c.to_bytes, [0x04, 0x7F, 0x80, 0x00, 0x00] )
      assert_equals( c.dump, "047F8000 00" )      
      
      # -Infinity
      c = FloatConstant.new( @java_class, Constant::CONSTANT_Float, 0xFF800000 )
      assert_equals( c.bytes.to_s,  "-Infinity" )
      assert_equals( c.to_s,  "-Infinity" )
      assert_equals( c.to_bytes, [0x04, 0xFF, 0x80, 0x00, 0x00] )
      assert_equals( c.dump, "04FF8000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes.to_s,  "-Infinity" )
      assert_equals( c.to_s,  "-Infinity" )
      assert_equals( c.to_bytes, [0x04, 0xFF, 0x80, 0x00, 0x00] )
      assert_equals( c.dump, "04FF8000 00" )     
      
    end
    
  end
  
  #
  #==DoubleConstantのテスト
  #
  class DoubleConstantTest <  RUNIT::TestCase
  
    def setup
      @java_class = JavaClass::Class.new
    end
  
    def teardown
    end
    
    #
    #=== 基本動作のテスト
    #
    def test_basic
      
      # 正の数
      c = DoubleConstant.new( @java_class, Constant::CONSTANT_Double, 0x4030800000000000 )
      assert_equals( c.bytes.to_s, "16.5" )
      assert_equals( c.to_s,  "16.5D" )
      assert_equals( c.to_bytes, [0x06, 0x40, 0x30, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "06403080 00000000 00" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.bytes.to_s, "16.5" )
      assert_equals( c.to_s,  "16.5D" )
      assert_equals( c.to_bytes, [0x06, 0x40, 0x30, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "06403080 00000000 00" )
      
      # 負の数
      c = DoubleConstant.new( @java_class, Constant::CONSTANT_Double, 0xC030800000000000 )
      assert_equals( c.bytes.to_s, "-16.5" )
      assert_equals( c.to_s,  "-16.5D" )
      assert_equals( c.to_bytes, [0x06, 0xC0, 0x30, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "06C03080 00000000 00" )

      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.bytes.to_s, "-16.5" )
      assert_equals( c.to_s,  "-16.5D" )
      assert_equals( c.to_bytes, [0x06, 0xC0, 0x30, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "06C03080 00000000 00" )
      
      # 0
      c = DoubleConstant.new( @java_class, Constant::CONSTANT_Double, 0x0000000000000000 )
      assert_equals( c.bytes.to_s, "0.0" )
      assert_equals( c.to_s,  "0.0D" )
      assert_equals( c.to_bytes, [0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "06000000 00000000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes.to_s, "0.0" )
      assert_equals( c.to_s,  "0.0D" )
      assert_equals( c.to_bytes, [0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "06000000 00000000 00" )   
      
      # Nan
      c = DoubleConstant.new( @java_class, Constant::CONSTANT_Double, 0x7FF8000000000000 )
      assert_equals( c.bytes.to_s,  "NaN" )
      assert_equals( c.to_s,  "NaN" )
      assert_equals( c.to_bytes, [0x06, 0x7F, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "067FF800 00000000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes.to_s,  "NaN" )
      assert_equals( c.to_s,  "NaN" )
      assert_equals( c.to_bytes, [0x06, 0x7F, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "067FF800 00000000 00" )     
      
      # Infinity
      c = DoubleConstant.new( @java_class, Constant::CONSTANT_Double, 0x7FF0000000000000 )
      assert_equals( c.bytes.to_s,  "Infinity" )
      assert_equals( c.to_s,  "Infinity" )
      assert_equals( c.to_bytes, [0x06, 0x7F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "067FF000 00000000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes.to_s,  "Infinity" )
      assert_equals( c.to_s,  "Infinity" )
      assert_equals( c.to_bytes, [0x06, 0x7F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "067FF000 00000000 00" )     
      
      # -Infinity
      c = DoubleConstant.new( @java_class, Constant::CONSTANT_Double, 0xFFF0000000000000 )
      assert_equals( c.bytes.to_s,  "-Infinity" )
      assert_equals( c.to_s,  "-Infinity" )
      assert_equals( c.to_bytes, [0x06, 0xFF, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "06FFF000 00000000 00" )      
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )      
      assert_equals( c.bytes.to_s,  "-Infinity" )
      assert_equals( c.to_s,  "-Infinity" )
      assert_equals( c.to_bytes, [0x06, 0xFF, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] )
      assert_equals( c.dump, "06FFF000 00000000 00" )    
      
    end
    
  end
  
  
  #
  #===StringConstantのテスト
  #
  class StringConstantTest <  RUNIT::TestCase
  
    def setup
      @java_class = JavaClass::Class.new
      # 0番は登録しておくが使われない。
      @java_class.constant_pool[0]   = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "xxx" )
      @java_class.constant_pool[1]   = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "aaa" )
      @java_class.constant_pool[10] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "bbb" )
    end
  
    def teardown
    end
    
    #
    #=== 基本動作のテスト
    #
    def test_basic
       
      c = StringConstant.new( @java_class, Constant::CONSTANT_String, 1 )
      assert_equals( c.bytes, "aaa" )
      assert_equals( c.to_s,  "\"aaa\"" )
      assert_equals( c.string_index, 1 )
      assert_equals( c.to_bytes, [0x08, 0x00, 0x01] )
      assert_equals( c.dump, "080001" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.bytes, "aaa" )
      assert_equals( c.to_s,  "\"aaa\"" )
      assert_equals( c.string_index, 1 )
      assert_equals( c.to_bytes, [0x08, 0x00, 0x01] )
      assert_equals( c.dump, "080001" )  
      
      c.string_index = 10
      assert_equals( c.bytes, "bbb" )
      assert_equals( c.to_s,  "\"bbb\"" )
      assert_equals( c.string_index, 10 )
      assert_equals( c.to_bytes, [0x08, 0x00, 0x0a] )
      assert_equals( c.dump, "08000A" )  
  
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.bytes, "bbb" )
      assert_equals( c.to_s,  "\"bbb\"" )
      assert_equals( c.string_index, 10 )
      assert_equals( c.to_bytes, [0x08, 0x00, 0x0a] )
      assert_equals( c.dump, "08000A" )  
      
      # 0番はnull扱い。
      c.string_index = 0
      assert_equals( c.bytes, nil )
      assert_equals( c.to_s,  "null" )
      assert_equals( c.string_index, 0 )
      assert_equals( c.to_bytes, [0x08, 0x00, 0x00] )
      assert_equals( c.dump, "080000" )  
  
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.bytes, nil )
      assert_equals( c.to_s,  "null" )
      assert_equals( c.string_index, 0 )
      assert_equals( c.to_bytes, [0x08, 0x00, 0x00] )
      assert_equals( c.dump, "080000" )  
    end
  end
  
  #
  #===NameAndTypeConstantのテスト
  #
  class NameAndTypeConstantTest <  RUNIT::TestCase
  
    def setup
      @java_class = JavaClass::Class.new
      @java_class.constant_pool[1]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "aaa" )
      @java_class.constant_pool[2]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "bbb" )
      @java_class.constant_pool[10] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "I" )
      @java_class.constant_pool[11] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "[I" )
    end
  
    def teardown
    end
    
    #
    #=== 基本動作のテスト
    #
    def test_basic
       
      c = NameAndTypeConstant.new( @java_class, Constant::CONSTANT_NameAndType, 1, 10 )
      assert_equals( c.name, "aaa" )
      assert_equals( c.descriptor, "I")
      assert_equals( c.name_index, 1 )
      assert_equals( c.descriptor_index, 10 )
      assert_equals( c.to_bytes, [0x0c, 0x00, 0x01, 0x00, 0x0a] )
      assert_equals( c.dump, "0C000100 0A" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.name, "aaa" )
      assert_equals( c.descriptor, "I")
      assert_equals( c.name_index, 1 )
      assert_equals( c.descriptor_index, 10 )
      assert_equals( c.to_bytes, [0x0c, 0x00, 0x01, 0x00, 0x0a] )
      assert_equals( c.dump, "0C000100 0A" ) 
      
      c.name_index = 2
      c.descriptor_index = 11
      assert_equals( c.name, "bbb" )
      assert_equals( c.descriptor, "[I")
      assert_equals( c.name_index, 2 )
      assert_equals( c.descriptor_index, 11 )
      assert_equals( c.to_bytes, [0x0c, 0x00, 0x02, 0x00, 0x0b] )
      assert_equals( c.dump, "0C000200 0B" ) 
  
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.name, "bbb" )
      assert_equals( c.descriptor, "[I")
      assert_equals( c.name_index, 2 )
      assert_equals( c.descriptor_index, 11 )
      assert_equals( c.to_bytes, [0x0c, 0x00, 0x02, 0x00, 0x0b] )
      assert_equals( c.dump, "0C000200 0B" ) 
    end
  end
  
  #
  #===ClassConstantのテスト
  #
  class ClassConstantTest <  RUNIT::TestCase
  
    def setup
      @java_class = JavaClass::Class.new
      @java_class.constant_pool[1]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "java/lang/Object" )
      @java_class.constant_pool[2]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "java/util/List" )
    end
  
    def teardown
    end
    
    #
    #=== 基本動作のテスト
    #
    def test_basic
       
      c = ClassConstant.new( @java_class, Constant::CONSTANT_Class, 1 )
      assert_equals( c.name, "java.lang.Object" )
      assert_equals( c.name_index, 1 )
      assert_equals( c.to_bytes, [0x07, 0x00, 0x01] )
      assert_equals( c.dump, "070001" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.name, "java.lang.Object" )
      assert_equals( c.name_index, 1 )
      assert_equals( c.to_bytes, [0x07, 0x00, 0x01] )
      assert_equals( c.dump, "070001" )
      
      c.name_index = 2
      assert_equals( c.name, "java.util.List" )
      assert_equals( c.name_index, 2 )
      assert_equals( c.to_bytes, [0x07, 0x00, 0x02] )
      assert_equals( c.dump, "070002" )
  
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.name, "java.util.List" )
      assert_equals( c.name_index, 2 )
      assert_equals( c.to_bytes, [0x07, 0x00, 0x02] )
      assert_equals( c.dump, "070002" )
    end
  end  
  
  #
  #===MemberRefConstantのテスト
  #
  class MemberRefConstantTest <  RUNIT::TestCase
  
    def setup
      @java_class = JavaClass::Class.new
      @java_class.constant_pool[1]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "aaa" )
      @java_class.constant_pool[2]  = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "bbb" )
      @java_class.constant_pool[10] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "I" )
      @java_class.constant_pool[11] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "[I" )
      @java_class.constant_pool[21] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "java/lang/Object" )
      @java_class.constant_pool[22] = UTF8Constant.new( @java_class, Constant::CONSTANT_Utf8, "java/util/List" )
      @java_class.constant_pool[31] = ClassConstant.new( @java_class, Constant::CONSTANT_Class, 21 )
      @java_class.constant_pool[32] = ClassConstant.new( @java_class, Constant::CONSTANT_Class, 22 )
      @java_class.constant_pool[41] = NameAndTypeConstant.new( @java_class, Constant::CONSTANT_NameAndType, 1, 10)
      @java_class.constant_pool[42] = NameAndTypeConstant.new( @java_class, Constant::CONSTANT_NameAndType, 2, 11)      
    end
  
    def teardown
    end
    
    #
    #=== FieldRefConstantの基本動作のテスト
    #
    def test_field_ref
       
      c = FieldRefConstant.new( @java_class, Constant::CONSTANT_Fieldref, 31, 41 )
      assert_equals( c.class_name.name, "java.lang.Object" )
      assert_equals( c.name_and_type.name, "aaa")
      assert_equals( c.class_name_index, 31 )
      assert_equals( c.name_and_type_index, 41 )
      assert_equals( c.to_bytes, [0x09, 0x00, 0x1F, 0x00, 0x29] )
      assert_equals( c.dump, "09001F00 29" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.class_name.name, "java.lang.Object" )
      assert_equals( c.name_and_type.name, "aaa")
      assert_equals( c.class_name_index, 31 )
      assert_equals( c.name_and_type_index, 41 )
      assert_equals( c.to_bytes, [0x09, 0x00, 0x1F, 0x00, 0x29] )
      assert_equals( c.dump, "09001F00 29" )
      
      c.class_name_index = 32
      c.name_and_type_index = 42
      assert_equals( c.class_name.name, "java.util.List" )
      assert_equals( c.name_and_type.name, "bbb")
      assert_equals( c.class_name_index, 32 )
      assert_equals( c.name_and_type_index, 42 )
      assert_equals( c.to_bytes, [0x09, 0x00, 0x20, 0x00, 0x2a] )
      assert_equals( c.dump, "09002000 2A" )
  
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.class_name.name, "java.util.List" )
      assert_equals( c.name_and_type.name, "bbb")
      assert_equals( c.class_name_index, 32 )
      assert_equals( c.name_and_type_index, 42 )
      assert_equals( c.to_bytes, [0x09, 0x00, 0x20, 0x00, 0x2a] )
      assert_equals( c.dump, "09002000 2A" )
    end
    
    #
    #=== MethodRefConstantの基本動作のテスト
    #
    def test_method_ref
       
      c = MethodRefConstant.new( @java_class, Constant::CONSTANT_Methodref, 31, 41 )
      assert_equals( c.class_name.name, "java.lang.Object" )
      assert_equals( c.name_and_type.name, "aaa")
      assert_equals( c.class_name_index, 31 )
      assert_equals( c.name_and_type_index, 41 )
      assert_equals( c.to_bytes, [0x0A, 0x00, 0x1F, 0x00, 0x29] )
      assert_equals( c.dump, "0A001F00 29" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.class_name.name, "java.lang.Object" )
      assert_equals( c.name_and_type.name, "aaa")
      assert_equals( c.class_name_index, 31 )
      assert_equals( c.name_and_type_index, 41 )
      assert_equals( c.to_bytes, [0x0A, 0x00, 0x1F, 0x00, 0x29] )
      assert_equals( c.dump, "0A001F00 29" )
      
      c.class_name_index = 32
      c.name_and_type_index = 42
      assert_equals( c.class_name.name, "java.util.List" )
      assert_equals( c.name_and_type.name, "bbb")
      assert_equals( c.class_name_index, 32 )
      assert_equals( c.name_and_type_index, 42 )
      assert_equals( c.to_bytes, [0x0A, 0x00, 0x20, 0x00, 0x2a] )
      assert_equals( c.dump, "0A002000 2A" )
  
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.class_name.name, "java.util.List" )
      assert_equals( c.name_and_type.name, "bbb")
      assert_equals( c.class_name_index, 32 )
      assert_equals( c.name_and_type_index, 42 )
      assert_equals( c.to_bytes, [0x0A, 0x00, 0x20, 0x00, 0x2a] )
      assert_equals( c.dump, "0A002000 2A" )
    end
    
    #
    #=== InterfaceMethodRefConstantの基本動作のテスト
    #
    def test_interface_method_ref
       
      c = InterfaceMethodRefConstant.new( @java_class, Constant::CONSTANT_InterfaceMethodref, 31, 41 )
      assert_equals( c.class_name.name, "java.lang.Object" )
      assert_equals( c.name_and_type.name, "aaa")
      assert_equals( c.class_name_index, 31 )
      assert_equals( c.name_and_type_index, 41 )
      assert_equals( c.to_bytes, [0x0B, 0x00, 0x1F, 0x00, 0x29] )
      assert_equals( c.dump, "0B001F00 29" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.class_name.name, "java.lang.Object" )
      assert_equals( c.name_and_type.name, "aaa")
      assert_equals( c.class_name_index, 31 )
      assert_equals( c.name_and_type_index, 41 )
      assert_equals( c.to_bytes, [0x0B, 0x00, 0x1F, 0x00, 0x29] )
      assert_equals( c.dump, "0B001F00 29" )
      
      c.class_name_index = 32
      c.name_and_type_index = 42
      assert_equals( c.class_name.name, "java.util.List" )
      assert_equals( c.name_and_type.name, "bbb")
      assert_equals( c.class_name_index, 32 )
      assert_equals( c.name_and_type_index, 42 )
      assert_equals( c.to_bytes, [0x0B, 0x00, 0x20, 0x00, 0x2a] )
      assert_equals( c.dump, "0B002000 2A" )
  
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.class_name.name, "java.util.List" )
      assert_equals( c.name_and_type.name, "bbb")
      assert_equals( c.class_name_index, 32 )
      assert_equals( c.name_and_type_index, 42 )
      assert_equals( c.to_bytes, [0x0B, 0x00, 0x20, 0x00, 0x2a] )
      assert_equals( c.dump, "0B002000 2A" )
    end    
    
    #
    #=== FieldRefConstantの基本動作のテスト
    #
    def test_field_ref
       
      c = FieldRefConstant.new( @java_class, Constant::CONSTANT_Fieldref, 31, 41 )
      assert_equals( c.class_name.name, "java.lang.Object" )
      assert_equals( c.name_and_type.name, "aaa")
      assert_equals( c.class_name_index, 31 )
      assert_equals( c.name_and_type_index, 41 )
      assert_equals( c.to_bytes, [0x09, 0x00, 0x1F, 0x00, 0x29] )
      assert_equals( c.dump, "09001F00 29" )
      
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.class_name.name, "java.lang.Object" )
      assert_equals( c.name_and_type.name, "aaa")
      assert_equals( c.class_name_index, 31 )
      assert_equals( c.name_and_type_index, 41 )
      assert_equals( c.to_bytes, [0x09, 0x00, 0x1F, 0x00, 0x29] )
      assert_equals( c.dump, "09001F00 29" )
      
      c.class_name_index = 32
      c.name_and_type_index = 42
      assert_equals( c.class_name.name, "java.util.List" )
      assert_equals( c.name_and_type.name, "bbb")
      assert_equals( c.class_name_index, 32 )
      assert_equals( c.name_and_type_index, 42 )
      assert_equals( c.to_bytes, [0x09, 0x00, 0x20, 0x00, 0x2a] )
      assert_equals( c.dump, "09002000 2A" )
  
      c = JavaClass.read_constant( ArrayIO.new( c.to_bytes ), @java_class )
      assert_equals( c.class_name.name, "java.util.List" )
      assert_equals( c.name_and_type.name, "bbb")
      assert_equals( c.class_name_index, 32 )
      assert_equals( c.name_and_type_index, 42 )
      assert_equals( c.to_bytes, [0x09, 0x00, 0x20, 0x00, 0x2a] )
      assert_equals( c.dump, "09002000 2A" )
    end        
  end  
  
module_function
  def assert_range_error( &block )
    begin
      block.call
      fail()
    rescue RangeError
    end
  end
end
