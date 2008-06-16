require "javaclass/base"

module JavaClass

  #
  #===クラス
  #
  class Class
    include JavaClass::Base
    include JavaClass::Converters
    include JavaClass::Item

    #
    #=== コンストラクタ
    #
    def initialize(  )
      @constant_pool = []
      @interface_indexs = []
      @fields  = []
      @methods = []
      @attributes = {}
    end

    #
    #===クラスバージョンを文字列で取得する
    #<b>戻り値</b>::クラスバージョン
    #
    def version
      @major_version.to_s << "." << @minor_version.to_s
    end

    #
    #=== クラス名を取得する。
    #<b>戻り値</b>::クラス名
    #
    def class_name
      get_constant(@this_class_index).name
    end

    #
    #=== 親クラス名を取得する。
    #<b>戻り値</b>::親クラス名
    #
    def super_class
      get_constant(@super_class_index).name
    end

    #
    #=== 実装しているインターフェイス名を配列で取得する。
    #<b>戻り値</b>::実装しているインターフェイス名の配列
    #
    def interfaces
      @interface_indexs.map {|i| get_constant(i).name }
    end

    #
    #=== ソースファイルを取得する。
    #<b>戻り値</b>::ソースファイル
    #
    def source_file
      attributes.key? 'SourceFile' ?
        attributes['SourceFile'].source_file : nil 
    end

    #
    #=== クラス名を取得する。
    #<b>戻り値</b>::クラス名
    #
    def enclosing_method
      attributes.key? 'EnclosingMethod' ?
        attributes['EnclosingMethod'] : nil 
    end

    #
    #=== クラスで利用しているインナークラスを配列で取得する。
    #<b>戻り値</b>::インナークラスの配列
    #
    def inner_classes
      attributes.key? 'InnerClasses' ?
        attributes['InnerClasses'].classes : []
    end

    #
    #===indexのConstantを取得する。
    #*index::constant_poolでのConstantのインデックス
    #<b>戻り値</b>::Constant
    #
    def get_constant( index )
      return nil if index == 0
      return @constant_pool[index]
    end
    #
    #===indexのConstantの値を取得する。
    #*index::constant_poolでのConstantのインデックス
    #<b>戻り値</b>::Constantの値
    #
    def get_constant_value( index )
      return nil if index == 0
      return @constant_pool[index].bytes
    end
    #
    #===indexのConstantの値の文字列表現を取得する。
    #*index::constant_poolでのConstantのインデックス
    #<b>戻り値</b>::Constantの値の文字列表現
    #
    def get_constant_as_string( index )
      return nil if index == 0
      return @constant_pool[index].to_s
    end

    # クラスの文字列表現を得る
    def to_s
      str =  "// version #{version}\n"
      str << attributes["Signature"].to_s << "\n" if attributes.key? "Signature"
      str << "// !deprecated!\n" if deprecated?
      str << "#{attributes['SourceFile'].to_s}\n" if attributes.key? 'SourceFile'
      str << "#{attributes['EnclosingMethod'].to_s}\n" if attributes.key? 'EnclosingMethod'
      str << annotations.inject( "" ){|s, e| s << e.to_s << "\n" }
      str << "#{access_flag.to_s} #{this_class.name} "
      str << "\nextends #{super_class.name} " if super_class.name != nil
      if interfaces.size > 0
        interface_names = interfaces.map {|interface| interface.name }
        str << "\nimplements #{interface_names.join(', ')} "
      end
      str << "{\n\n"
      inner_classes.classes.each {|inner_class|
        str << "    " << inner_class.to_s << "\n"
      }
      str << "\n"
      @fields.each {|f|
        str << indent( f.to_s + ";", 4 ) << "\n"
      }
      str << "\n"
      @methods.each {|m|
        str << indent( m.to_s, 4 ) << "\n"
      }
      str << "\n}"
    end

    def indent( str, size )
      indent = " "*size
      indent += str.gsub( /\n/, "\n" << " "*size  )
    end

    def to_bytes()
      bytes = to_byte( 0xCAFEBABE, 4)
      bytes += to_byte( @minor_version, 2)
      bytes += to_byte( @major_version, 2)
      
      constant_pool_length = @constant_pool.inject(1){|i, c|  
        if c.tag == JavaClass::Constant::CONSTANT_Double \
          || c.tag == JavaClass::Constant::CONSTANT_Long
          i += 2
        else 
          i += 1
        end
      }
      bytes += to_byte( constant_pool_length, 2)
      @constant_pool.each {|c|
        bytes += c.to_bytes() if c != nil
      }
      bytes += @access_flag.to_bytes()
      bytes += to_byte( @this_class_index, 2)
      bytes += to_byte( @super_class_index, 2)
      bytes += to_byte( @interface_indexs.length, 2)
      @interface_indexs.each {|i|
        bytes += to_byte( i, 2)
      }
      bytes += to_byte( @fields.length, 2)
      @fields.each {|f|
        bytes += f.to_bytes()
      }
      bytes += to_byte( @methods.length, 2)
      @methods.each {|m|
        bytes += m.to_bytes()
      }
      bytes += to_byte( @attributes.size, 2)
      @attributes.keys.sort!.each {|k| 
        bytes += @attributes[k].to_bytes()
      }
      return bytes
    end

    attr :major_version, true
    attr :minor_version, true
    attr :constant_pool, true
    attr :access_flag, true
    attr :this_class_index, true
    attr :super_class_index, true
    attr :interface_indexs, true
    attr :fields, true
    attr :methods, true
    attr :attributes, true
  end

end