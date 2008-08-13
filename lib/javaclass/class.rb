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
    def name
      c = get_constant(@this_class_index)
      c ? c.name : nil 
    end

    #
    #=== 親クラス名を取得する。
    #<b>戻り値</b>::親クラス名
    #
    def super_class
      c = get_constant(@super_class_index)
      c ? c.name : nil 
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
      attributes.key?('SourceFile') ?
        attributes['SourceFile'].source_file : nil 
    end

    #
    #=== クラス名を取得する。
    #<b>戻り値</b>::クラス名
    #
    def enclosing_method
      attributes.key?('EnclosingMethod') ?
        attributes['EnclosingMethod'] : nil 
    end

    #
    #=== クラスで利用しているインナークラスを配列で取得する。
    #<b>戻り値</b>::インナークラスの配列
    #
    def inner_classes
      attributes.key?('InnerClasses') ?
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
    #
    #===同じConstantがなければ追加する。
    #*constant::Constant
    #<b>戻り値</b>::追加したConstantのインデックス。すでに存在する場合、そのインデックス。
    #
    def put_constant( constant )
      index = @constant_pool.index constant
      if index == nil
        constant.java_class = self
        index = @constant_pool.push( constant ).length-1
        # doubleとlongの場合、次は欠番
        tag = constant.tag
        if tag == JavaClass::Constant::CONSTANT_Double \
          || tag == JavaClass::Constant::CONSTANT_Long
          @constant_pool.push( nil )
        end
      end
      return index
    end
    
    #
    #===UTF8Constantがプールになければ追加する。
    #*value::文字列値
    #<b>戻り値</b>::追加したConstantのインデックス。すでに存在する場合、そのインデックス。
    #
    def put_utf8_constant( value )
      put_constant( UTF8Constant.new( nil, Constant::CONSTANT_Utf8, value ))
    end
    
    #
    #===整数型のConstantがプールになければ追加する。
    #*value::整数値
    #<b>戻り値</b>::追加したConstantのインデックス。すでに存在する場合、そのインデックス。
    #
    def put_integer_constant( value )
      put_constant( IntegerConstant.new( nil, Constant::CONSTANT_Integer, value ))
    end
    
    #
    #===整数(Long)型のConstantがプールになければ追加する。
    #*value::整数値
    #<b>戻り値</b>::追加したConstantのインデックス。すでに存在する場合、そのインデックス。
    #
    def put_long_constant( value )
      put_constant( LongConstant.new( nil, Constant::CONSTANT_Long, value ))
    end
    
    #
    #===文字列型のConstantがプールになければ追加する。
    #*value::文字列値
    #<b>戻り値</b>::追加したConstantのインデックス。すでに存在する場合、そのインデックス。
    #
    def put_string_constant( value )
      put_constant( StringConstant.new( nil, Constant::CONSTANT_String, 
        put_utf8_constant( value ) ))
    end
    
    
    #
    #===条件にマッチするメソッドを取得する。
    #*name::メソッド名
    #*return_type::戻り値型(省略した場合、戻り値を問わない)
    #*parameters::引数型の配列(省略した場合、パラメータタイプを問わない)
    #<b>戻り値</b>::条件にマッチするメソッド。存在しない場合nil
    #
    def find_method( name, return_type=nil, parameters=nil )
      @methods.find {|m|
        ( m.name.eql?( name ) ) \
        && ( return_type != nil ? m.return_type.eql?(return_type) : true ) \
        && ( parameters  != nil ? m.parameters.eql?(parameters)   : true )
      }
    end
    
    #
    #===条件にマッチするフィールドを取得する。
    #*name::メソッド名
    #*return_type::戻り値型(省略した場合、戻り値を問わない)
    #*parameters::引数型の配列(省略した場合、パラメータタイプを問わない)
    #<b>戻り値</b>::条件にマッチするメソッド。存在しない場合nil
    #
    def find_field( name )
      @fields.find {|f|
        f.name.eql?( name ) 
      }
    end
  
    def new_field
      
    end
    
    def new_method( name, descriptor )
      
    end
    
  
    # クラスの文字列表現を得る
    def to_s
      str =  "// version #{version}\n"
      str << attributes["Signature"].to_s << "\n" if attributes.key? "Signature"
      str << "// !deprecated!\n" if deprecated?
      str << "#{attributes['SourceFile'].to_s}\n" if attributes.key? 'SourceFile'
      str << "#{attributes['EnclosingMethod'].to_s}\n" if attributes.key? 'EnclosingMethod'
      str << annotations.inject( "" ){|s, e| s << e.to_s << "\n" }
      str << "#{access_flag.to_s} #{name} "
      str << "\nextends #{super_class} " if super_class != nil
      if interfaces.size > 0
        interface_names = interfaces.map {|interface| interface }
        str << "\nimplements #{interface_names.join(', ')} "
      end
      str << "{\n\n"
      inner_classes.each {|inner_class|
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
      ind = " "*size
      ind += str.gsub( /\n/, "\n" << " "*size  )
    end

    def to_bytes()
      bytes = to_byte( 0xCAFEBABE, 4)
      bytes += to_byte( @minor_version, 2)
      bytes += to_byte( @major_version, 2)
      
      bytes += to_byte( @constant_pool.length, 2)
      @constant_pool.each {|c|
        bytes += c.to_bytes() if c != nil
      }
      bytes += @access_flag.to_bytes()
      bytes += to_byte( @this_class_index, 2)
      bytes += to_byte( @super_class_index, 2)
      bytes += to_byte( @interface_indexs.length, 2)
      @interface_indexs.each {|i|
        bytes += to_byte( i, 2 )
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