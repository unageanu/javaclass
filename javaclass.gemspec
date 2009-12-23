Gem::Specification.new do |spec|
  spec.name = "javaclass"
  spec.version = "0.3.0"
  spec.summary = "javaclass is a java class file parser for ruby."
  spec.author = "Masaya Yamauchi"
  spec.email = "y-masaya@red.hot.co.jp"
  spec.homepage = "http://github.com/unageanu/javaclass/tree/master"
  spec.test_files = Dir.glob( "test/*" )
  spec.files = [
    "README",
    "javaclass.gemspec",
    "ChangeLog"
  ]+Dir.glob( "lib/*" )+Dir.glob( "sample/*" )+spec.test_files
  spec.has_rdoc = true
  spec.rdoc_options << "--main" << "README"
  spec.extra_rdoc_files = ["README"]
  spec.add_dependency('rubyzip', '>= 0.9.1')
end
