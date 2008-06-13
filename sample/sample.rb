
$: << "../src"

require "javaclass"
require "kconv"

[
#  "./java_class/com/example/Kitten.class",
#  "./java_class/HelloWorld.class",
#  "./java_class/com/example/Constants.class",
#  "./java_class/com/example/InnerClass.class",
#  "./java_class/com/example/InnerClassImpl.class",
#  "./java_class/com/example/InnerClass$StaticInnerClass.class",
#  "./java_class/com/example/ThrowsException.class",
#  "./java_class/com/example/InnerClassImpl$1MethodInnerClass.class",
#  "./java_class/com/example/InnerClassImpl$2.class",
#  "./java_class/com/example/types/TypeVariables.class",
#  "./java_class/com/example/Deprecated.class",
  "./java_class/com/example/annotation/Annotated.class",
#  "./java_class/com/example/annotation/HasDefaultValue.class",
#  "./java_class/com/example/annotation/AnnotatedMethod.class"
].each { |c|
  open( c, "r+b" ) {|io|
    jc = JavaClass.from io
    puts jc.to_s.tosjis
    puts ""
  }
}