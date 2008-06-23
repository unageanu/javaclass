
require "zip/zip"

# ZipInputStreamにはgetcが実装されていないので、追加する。
module Zip
  class ZipInputStream
    def getc
      read(1)[0]
    end
  end
end

module JavaClass
  
  #=== Zipユーティリティ
  module ZipUtils
  module_function
  
    # Zipエントリ内のクラス一覧を列挙して解析する。
    #*zip_file:: zipファイル
    #*&block:: クラスごとに呼び出されるブロック。引数でJavaClass::Classが渡される。
    def each_class ( zip_file, &block ) 
      Zip::ZipFile.foreach(zip_file) {|entry|
        next unless entry.file?
        next unless entry.name =~ /.*\.class$/
        entry.get_input_stream {|io|
          jc = JavaClass.from io
          block.call( jc ) if block_given?
        }
      }
    end
  end
end