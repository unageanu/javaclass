require "javaclass/util"

module JavaClass


  #
  #===クラス
  #
  class Class
    include JavaClass::Util

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
    #=== このクラスを示すClassConstantを取得する。
    #<b>戻り値</b>::このクラスを示すClassConstant
    #
    def this_class
      get_constant(@this_class_index)
    end

    #
    #=== 親クラスを示すClassConstantを取得する。
    #<b>戻り値</b>::親クラスを示すClassConstant
    #
    def super_class
        get_constant(@super_class_index)
    end

    #
    #=== 実装しているインターフェイスのClassConstantを配列で取得する。
    #<b>戻り値</b>::実装しているインターフェイスのClassConstantの配列
    #
    def interfaces
      @interface_indexs.map {|i| get_constant(i) }
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
      str << "#{attributes['Signature'].to_s}\n" if attributes.key? 'Signature'
	    str << "#{attributes['Deprecated'].to_s}\n" if attributes.key? 'Deprecated'
      str << "#{attributes['SourceFile'].to_s}\n" if attributes.key? 'SourceFile'
      str << "#{attributes['EnclosingMethod'].to_s}\n" if attributes.key? 'EnclosingMethod'
      str << "#{attributes['RuntimeVisibleAnnotations'].to_s}\n" if attributes.key? 'RuntimeVisibleAnnotations'
      str << "#{attributes['RuntimeInvisibleAnnotations'].to_s}\n" if attributes.key? 'RuntimeInvisibleAnnotations'
      str << "#{access_flag.to_s} #{this_class.name} "
      str << "\nextends #{super_class.name} " if super_class.name != nil
      if interfaces.size > 0
        interface_names = interfaces.map {|interface| interface.name }
        str << "\nimplements #{interface_names.join(', ')} "
      end
      str << "{\n\n"
      if ( attributes.key?  'InnerClasses' )
        attributes['InnerClasses'].classes.each {|inner_class|
          str << "    " << inner_class.to_s << "\n"
        }
        str << "\n"
      end
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
      bytes += to_byte( @constant_pool.size+1, 2)
      @constant_pool.each {|c|
        next if c == nil
        bytes += c.to_bytes()
      }
      bytes += @access_flag.to_bytes()
      # TODO クラスとか。
      #bytes += to_byte( @fields.size, 2)
      #@fields.each {|f| f.to_bytes(bytes)}
      #to_byte( @methods.size, 2, bytes)
      #@methods.each {|m| m.to_bytes(bytes)}
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