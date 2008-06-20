
require "rubygems"
require "javaclass"
require "zip/zip"


module Zip
  class ZipInputStream
    def getc
      read(1)[0]
    end
  end
end

Zip::ZipFile.foreach(ARGV[0]) {|entry|
  next unless entry.file?
  next unless entry.name =~ /.*\.class$/
  entry.get_input_stream {|io|
    jc = JavaClass.from io
    puts jc.name
  }
}