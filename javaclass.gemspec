Gem::Specification.new do |spec|
  spec.name = "javaclass"
  spec.version = "0.0.1"
  spec.summary = "javaclass is a java class file parser for ruby."
  spec.author = "Masaya Yamauchi"
  spec.email = "y-masaya@red.hot.co.jp"
  spec.homepage = "http://github.com/unageanu/javaclass/tree/master"
  spec.files = Dir.glob("{test,lib}/**/*") << "README" << "ChangeLog"
  spec.test_files = Dir.glob("test/**/*") 
  spec.has_rdoc = true
  spec.rdoc_options << "--main" << "README"
  spec.extra_rdoc_files = ["README"]
end  