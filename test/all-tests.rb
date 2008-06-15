
$: << "../src"

require 'test/unit/testsuite'
require 'access-flag-test'
require 'attribute-test'
require 'constant-test'
require 'member-test'

module JavaClass

  class AllTests
    def self.suite
      suite = Test::Unit::TestSuite.new( "javaclass all tests." )
      suite << AccessFlagTest.suite
      suite << AttributeTest.suite
      suite << AttributeTest.suite
      suite << UTF8ConstantTest
      suite << IntegerConstantTest
      suite << LongConstantTest.suite
      suite << FloatConstantTest.suite
      suite << DoubleConstantTest.suite
      suite << StringConstantTest.suite
      suite << NameAndTypeConstantTest.suite
      suite << ClassConstantTest.suite
      suite << MemberRefConstantTest.suite
      suite << MemberTest.suite
      return suite
    end
  end

end