#!/usr/bin/ruby

$: << "../lib"

require "test/unit"
require "javaclass"
require "test_util"

require "javaclass"

module JavaClass

#
#=== AccessFlagのテスト。
#
class AccessFlagTest < Test::Unit::TestCase

  def setup
  end

  def teardown
  end

  def test_class_access_flag

    a = ClassAccessFlag.new( ClassAccessFlag::ACC_PUBLIC )
    assert_equal a.to_s, "public class"
    assert_equal a.dump, "0001"
    assert_equal a.source_modifiers, []
    assert_equal a.accessor, "public"
    assert_equal a.type, "class"
    assert  a.on?(ClassAccessFlag::ACC_PUBLIC)
    assert  !a.on?(ClassAccessFlag::ACC_FINAL)
    assert  !a.on?(ClassAccessFlag::ACC_ABSTRACT)

    a.on( ClassAccessFlag::ACC_INTERFACE )
    a.on( ClassAccessFlag::ACC_ABSTRACT )
    assert_equal a.to_s, "public abstract interface"
    assert_equal a.dump, "0601"
    assert_equal a.source_modifiers, ["abstract"]
    assert_equal a.accessor, "public"
    assert_equal a.type, "interface"
    assert  a.on?(ClassAccessFlag::ACC_PUBLIC)
    assert  a.on?(ClassAccessFlag::ACC_INTERFACE)
    assert  !a.on?(ClassAccessFlag::ACC_FINAL)
    assert  a.on?(ClassAccessFlag::ACC_ABSTRACT)

    a.off( ClassAccessFlag::ACC_INTERFACE )
    a.off( ClassAccessFlag::ACC_ABSTRACT )
    a.off( ClassAccessFlag::ACC_PUBLIC )
    a.on( ClassAccessFlag::ACC_ENUM )
    assert_equal a.to_s, "enum"
    assert_equal a.dump, "4000"
    assert_equal a.source_modifiers, []
    assert_equal a.accessor, ""
    assert_equal a.type, "enum"
    assert  !a.on?(ClassAccessFlag::ACC_PUBLIC)
    assert  !a.on?(ClassAccessFlag::ACC_INTERFACE)
    assert  !a.on?(ClassAccessFlag::ACC_FINAL)
    assert  a.on?(ClassAccessFlag::ACC_ENUM)

    a.off( ClassAccessFlag::ACC_ENUM )
    a.on( ClassAccessFlag::ACC_PUBLIC )
    a.on( ClassAccessFlag::ACC_ANNOTATION )
    a.on( ClassAccessFlag::ACC_INTERFACE )
    assert_equal a.to_s, "public @interface"
    assert_equal a.dump, "2201"
    assert_equal a.source_modifiers, []
    assert_equal a.accessor, "public"
    assert_equal a.type, "@interface"
    assert  a.on?(ClassAccessFlag::ACC_PUBLIC)
    assert  a.on?(ClassAccessFlag::ACC_INTERFACE)
    assert  !a.on?(ClassAccessFlag::ACC_FINAL)
    assert  a.on?(ClassAccessFlag::ACC_ANNOTATION)

  end
  def test_field_access_flag

    a = FieldAccessFlag.new( FieldAccessFlag::ACC_PUBLIC )
    assert_equal a.to_s, "public"
    assert_equal a.dump, "0001"
    assert_equal a.source_modifiers, []
    assert_equal a.accessor, "public"
    assert  a.on?(FieldAccessFlag::ACC_PUBLIC)
    assert  !a.on?(FieldAccessFlag::ACC_FINAL)
    assert  !a.on?(FieldAccessFlag::ACC_STATIC)

    a.off( FieldAccessFlag::ACC_PUBLIC )
    a.on( FieldAccessFlag::ACC_PROTECTED )
    a.on( FieldAccessFlag::ACC_STATIC )
    a.on( FieldAccessFlag::ACC_FINAL )
    a.on( FieldAccessFlag::ACC_ENUM )
    assert_equal a.to_s, "protected static final"
    assert_equal a.dump, "401C"
    assert_equal a.source_modifiers, ["static","final"]
    assert_equal a.accessor, "protected"

    a.off( FieldAccessFlag::ACC_PROTECTED )
    a.on( FieldAccessFlag::ACC_PRIVATE )
    a.on( FieldAccessFlag::ACC_VOLATILE )
    a.on( FieldAccessFlag::ACC_TRANSIENT )
    a.off( FieldAccessFlag::ACC_STATIC )
    a.off( FieldAccessFlag::ACC_FINAL )
    a.off( FieldAccessFlag::ACC_ENUM )
    assert_equal a.to_s, "private volatile transient"
    assert_equal a.dump, "00C2"
    assert_equal a.source_modifiers, ["volatile","transient"]
    assert_equal a.accessor, "private"

    a.off( FieldAccessFlag::ACC_PRIVATE )
    a.off( FieldAccessFlag::ACC_VOLATILE )
    a.off( FieldAccessFlag::ACC_TRANSIENT )
    assert_equal a.to_s, ""
    assert_equal a.dump, "0000"
    assert_equal a.source_modifiers, []
    assert_equal a.accessor, ""

  end

  def test_method_access_flag

    a = MethodAccessFlag.new( MethodAccessFlag::ACC_PUBLIC )
    assert_equal a.to_s, "public"
    assert_equal a.dump, "0001"
    assert_equal a.source_modifiers, []
    assert_equal a.accessor, "public"
    assert  a.on?(MethodAccessFlag::ACC_PUBLIC)
    assert  !a.on?(MethodAccessFlag::ACC_FINAL)
    assert  !a.on?(MethodAccessFlag::ACC_STATIC)

    a.off( MethodAccessFlag::ACC_PUBLIC )
    a.on( MethodAccessFlag::ACC_PROTECTED )
    a.on( MethodAccessFlag::ACC_STATIC )
    a.on( MethodAccessFlag::ACC_FINAL )
    assert_equal a.to_s, "protected static final"
    assert_equal a.dump, "001C"
    assert_equal a.source_modifiers, ["static","final"]
    assert_equal a.accessor, "protected"

    a.off( MethodAccessFlag::ACC_PROTECTED )
    a.on( MethodAccessFlag::ACC_PRIVATE )
    a.on( MethodAccessFlag::ACC_NATIVE )
    a.on( MethodAccessFlag::ACC_VARARGS )
    a.on( MethodAccessFlag::ACC_SYNCHRONIZED)
    a.off( MethodAccessFlag::ACC_STATIC )
    a.off( MethodAccessFlag::ACC_FINAL )
    assert_equal a.to_s, "private synchronized native"
    assert_equal a.dump, "01A2"
    assert_equal a.source_modifiers, ["synchronized", "native"]
    assert_equal a.accessor, "private"

    a.off( MethodAccessFlag::ACC_PRIVATE )
    a.off( MethodAccessFlag::ACC_NATIVE )
    a.off( MethodAccessFlag::ACC_VARARGS )
    a.off( MethodAccessFlag::ACC_SYNCHRONIZED)
    assert_equal a.to_s, ""
    assert_equal a.dump, "0000"
    assert_equal a.source_modifiers, []
    assert_equal a.accessor, ""

  end

  def test_inner_class_access_flag

    a = InnerClassAccessFlag.new( InnerClassAccessFlag::ACC_PUBLIC )
    assert_equal a.to_s, "public class"
    assert_equal a.dump, "0001"
    assert_equal a.source_modifiers, []
    assert_equal a.accessor, "public"
    assert  a.on?(InnerClassAccessFlag::ACC_PUBLIC)
    assert  !a.on?(InnerClassAccessFlag::ACC_FINAL)
    assert  !a.on?(InnerClassAccessFlag::ACC_STATIC)

    a.off( InnerClassAccessFlag::ACC_PUBLIC )
    a.on( InnerClassAccessFlag::ACC_PROTECTED )
    a.on( InnerClassAccessFlag::ACC_STATIC )
    a.on( InnerClassAccessFlag::ACC_FINAL )
    assert_equal a.to_s, "protected static final class"
    assert_equal a.dump, "001C"
    assert_equal a.source_modifiers, ["static","final"]
    assert_equal a.accessor, "protected"

    a.off( InnerClassAccessFlag::ACC_PROTECTED )
    a.on( InnerClassAccessFlag::ACC_PRIVATE )
    a.on( InnerClassAccessFlag::ACC_SYNTHETIC )
    a.on( InnerClassAccessFlag::ACC_ENUM )
    a.off( InnerClassAccessFlag::ACC_STATIC )
    a.off( InnerClassAccessFlag::ACC_FINAL )
    assert_equal a.to_s, "private enum"
    assert_equal a.dump, "5002"
    assert_equal a.source_modifiers, []
    assert_equal a.accessor, "private"

    a.off( InnerClassAccessFlag::ACC_PRIVATE )
    a.off( InnerClassAccessFlag::ACC_SYNTHETIC )
    a.off( InnerClassAccessFlag::ACC_ENUM)
    assert_equal a.to_s, "class"
    assert_equal a.dump, "0000"
    assert_equal a.source_modifiers, []
    assert_equal a.accessor, ""

  end  
  
end
end
