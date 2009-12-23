require "javaclass/base"

module JavaClass

  #
  #=== 属性の基底クラス
  #
  class Attribute
    include JavaClass::Base
    
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #
    def initialize( java_class, name_index )
      @java_class = java_class
      @name_index = name_index
    end
    #
    #===属性名を取得する。
    #
    #<b>戻り値</b>::属性名
    #
    def name
      @java_class.get_constant_value(@name_index)
    end

    def to_bytes
      to_byte( @name_index, 2)
    end

    attr :java_class, true
    attr :name_index, true
  end

  #
  #=== 定数値属性
  #
  class ConstantValueAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*constant_value_index::定数値を示すconstant_poolのインデックス
    #
    def initialize( java_class, name_index, constant_value_index )
      super( java_class, name_index)
      @constant_value_index = constant_value_index
    end
    #
    #===定数値を取得する。
    #
    #<b>戻り値</b>::定数値
    #
    def value
      @java_class.get_constant_value(@constant_value_index)
    end
    #
    #===定数値の文字列表現を取得する。
    #
    #<b>戻り値</b>::定数値の文字列表現
    #
    def to_s
      @java_class.get_constant_as_string(@constant_value_index)
    end

    def to_bytes
      bytes = super
      bytes += to_byte( 2, 4)
      bytes += to_byte( @constant_value_index, 2)
    end
   
    #定数値を示すconstant_poolのインデックス
    attr :constant_value_index, true
  end

  #
  #=== 例外属性
  #
  class ExceptionsAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*constant_value_index::定数値を示すconstant_poolのインデックス
    #
    def initialize( java_class, name_index, exception_index_table )
      super( java_class, name_index)
      @exception_index_table = exception_index_table
    end
    #
    #===例外の配列を取得する。
    #
    #<b>戻り値</b>::例外の配列
    #
    def exceptions
      exception_index_table.map() {|index|
        @java_class.get_constant(index)
      }
    end
    def to_s
      "throws " << exceptions.map(){|ex| ex.name }.join(", ")
    end
    def to_bytes
      bytes = super
      bytes += to_byte( 2+(2 * (@exception_index_table.length)), 4)
      bytes += to_byte( @exception_index_table.length, 2)
      @exception_index_table.each {|index|
        bytes += to_byte( index, 2)
      }
      return bytes
    end
    #例外テーブル
    attr :exception_index_table, true
  end

  #
  #=== インナークラス属性
  #
  class InnerClassesAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*constant_value_index::定数値を示すconstant_poolのインデックス
    #
    def initialize( java_class, name_index, classes )
      super( java_class, name_index)
      @classes = classes
    end
    def to_s
      @classes.map{|c| c.to_s }.join( "\n" )
    end
    def to_bytes
      bytes = super
      body = to_byte( @classes.length, 2)
      @classes.each {|c|
        body += c.to_bytes()
      }
      bytes += to_byte( body.length, 4)
      bytes += body
    end
    
    # インナークラスの配列
    attr :classes, true
  end

  #
  #=== インナークラス
  #
  class InnerClass
    include JavaClass::Base
    
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*inner_class_index::インナークラス情報を示すconstant_poolのインデックス
    #*outer_class_index::インナークラスを所有するクラスの情報を示すconstant_poolのインデックス
    #*name_index::インナークラス名を示すconstant_poolのインデックス
    #*access_flag::アクセスフラグ
    #
    def initialize( java_class, inner_class_index=nil, \
      outer_class_index=nil, name_index=nil, access_flag=nil )
      @java_class = java_class
      @inner_class_index = inner_class_index
      @outer_class_index = outer_class_index
      @name_index = name_index
      @access_flag = access_flag
    end

    #
    #===インナークラスの情報を取得する。
    #
    #<b>戻り値</b>::インナークラスの情報。
    #
    def inner_class
      @java_class.get_constant( @inner_class_index )
    end

    #
    #===インナークラスを所有するクラスの情報を取得する。
    #
    #<b>戻り値</b>::インナークラスを所有するクラスの情報。匿名クラスの場合はnullが返される。
    #
    def outer_class
      @java_class.get_constant( @outer_class_index )
    end
    #
    #===インナークラスの名前を取得する。無名クラスの場合nilが返される
    #
    #<b>戻り値</b>::インナークラスの名前。無名クラスの場合nilが返される
    #
    def name
      @name_index == 0 ? nil : @java_class.get_constant_value(@name_index)
    end
    def to_s
      str = "// use inner #{@access_flag.to_s}"
      str << " " << inner_class.name if inner_class != nil
      return str
    end
    def to_bytes
      bytes =  to_byte( @inner_class_index, 2)
      bytes += to_byte( @outer_class_index, 2)
      bytes += to_byte( @name_index, 2)
      bytes += @access_flag.to_bytes()
    end
    # インナークラス情報を示すconstant_poolのインデックス
    attr :inner_class_index, true
    # インナークラスを所有するクラスの情報を示すconstant_poolのインデックス
    attr :outer_class_index, true
    # インナークラス名を示すconstant_poolのインデックス
    attr :name_index, true
    # アクセスフラグ
    attr :access_flag, true
  end

  #
  #=== クラスを同封するメソッドの属性
  #
  class EnclosingMethodAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*enclosing_class_index::クラスを同封するメソッドを持つクラスの情報を示すconstant_poolのインデックス
    #*enclosing_method_index::クラスを同封するメソッドの情報を示すconstant_poolのインデックス
    #
    def initialize( java_class, name_index, class_index, method_index )
      super( java_class, name_index)
      @enclosing_class_index = class_index
      @enclosing_method_index = method_index
    end
    #
    #===クラスを同封するメソッドを持つクラスの情報を取得する。
    #
    #<b>戻り値</b>::クラスを同封するメソッドを持つクラスの情報
    #
    def enclosing_class
      @java_class.get_constant( @enclosing_class_index )
    end
    #
    #===クラスを同封するメソッドの情報を取得する。
    #
    #<b>戻り値</b>::クラスを同封するメソッドの情報
    #
    def enclosing_method
      @java_class.get_constant( @enclosing_method_index )
    end
    def to_s
      "// enclosed by #{enclosing_class.name}##{enclosing_method.name}"
    end
    def to_bytes
      bytes = super
      bytes += to_byte( 4, 4 )
      bytes += to_byte( @enclosing_class_index, 2 )
      bytes += to_byte( @enclosing_method_index, 2 )
    end
    
    # クラスを同封するメソッドを持つクラスの情報を示すconstant_poolのインデックス
    attr :enclosing_class_index, true
    # クラスを同封するメソッドの情報を示すconstant_poolのインデックス
    attr :enclosing_method_index, true
  end


  #
  #=== Deprecated属性
  #
  class DeprecatedAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #
    def initialize( java_class, name_index )
      super( java_class, name_index)
    end
    def to_s
      "// !!Deprecated!!"
    end
    def to_bytes
      bytes = super
      bytes += to_byte( 0, 4 )
    end
  end

  #
  #=== Synthetic属性
  #
  class SyntheticAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #
    def initialize( java_class, name_index )
      super( java_class, name_index)
    end
    def to_bytes
      bytes = super
      bytes += to_byte( 0, 4 )
    end
  end

  #
  #=== ソースファイル属性
  #
  class SourceFileAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*source_file_index::ソースファイルを示すconstant_poolのインデックス
    #
    def initialize( java_class, name_index, source_file_index )
      super( java_class, name_index)
      @source_file_index = source_file_index
    end
    #
    #===ソースファイル名を取得する。
    #
    #<b>戻り値</b>::ソースファイル名
    #
    def source_file
      @java_class.get_constant_value(@source_file_index)
    end
    def to_s
      "// source #{source_file}"
    end
    def to_bytes
      bytes = super
      bytes += to_byte( 2, 4)
      bytes += to_byte( @source_file_index, 2)
    end
    # ソースファイルを示すconstant_poolのインデックス
    attr :source_file_index, true
  end

  #
  #=== ソースデバッグ拡張属性
  #
  class SourceDebugExtensionAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*debug_extension::デバッグ情報
    #
    def initialize( java_class, name_index, debug_extension )
      super( java_class, name_index)
      @debug_extension = debug_extension
    end
    def to_s
      "// debug_extension #{debug_extension}"
    end
    def to_bytes
      bytes = super
      body = []
      @debug_extension.each_byte {|i|
        body += to_byte( i, 1 )
      }
      bytes += to_byte( body.length, 4 )
      bytes += body
    end
    
    # デバッグ情報
    attr :debug_extension, true
  end

  #
  #=== シグネチャ属性
  #
  class SignatureAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*signature_index::シグネチャを示すconstant_poolのインデックス
    #
    def initialize( java_class, name_index, signature_index )
      super( java_class, name_index)
      @signature_index = signature_index
    end
    #
    #===シグネチャを取得する。
    #
    #<b>戻り値</b>::シグネチャ
    #
    def signature
      @java_class.get_constant_value(@signature_index)
    end
    def to_s
      "// signature #{signature}"
    end
    def to_bytes
      bytes = super
      bytes += to_byte( 2, 4)
      bytes += to_byte( @signature_index, 2)
    end
    # シグネチャを示すconstant_poolのインデックス
    attr :signature_index, true
  end

  #
  #=== アノテーション属性
  #
  class AnnotationsAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*annotations::アノテーションの配列
    #
    def initialize( java_class, name_index, annotations=[] )
      super( java_class, name_index)
      @annotations = annotations
    end
    def to_s
      @annotations.map{|a| a.to_s }.join("\n")
    end
    def to_bytes
      bytes = super
      body = to_byte( @annotations.length, 2)
      @annotations.each {|c|
        body += c.to_bytes()
      }
      bytes += to_byte( body.length, 4)
      bytes += body
    end

    attr :annotations, true
  end

  #
  #=== アノテーション
  #
  class Annotation
    include JavaClass::Base
    include JavaClass::Converters
    
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*type_index::アノテーションの種別を示すconstant_poolのインデックス
    #*elements::アノテーションのデータペア一覧
    #
    def initialize( java_class, type_index, elements={} )
      @java_class = java_class
      @type_index = type_index
      @elements = elements
    end
    def type
      @java_class.get_constant_value(@type_index)
    end
    def to_s
      str = "@" << convert_field_descriptor(type)
      str << "(\n" unless @elements.empty?
      str << @elements.map {|k,v| "    " << v.to_s }.join( ",\n" )
      str << "\n)" unless @elements.empty?
      return str
    end
    def to_bytes
      bytes = to_byte( @type_index, 2)
      bytes += to_byte( @elements.size, 2)
      @elements.each {|k,v|
        bytes += v.to_bytes()
      }
      return bytes
    end

    attr :type_index, true
    attr :elements, true
  end
  #
  #=== アノテーションのデータ
  #
  class AnnotationElement
    include JavaClass::Base

    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*value::値
    #
    def initialize( java_class, name_index=nil, value=nil )
      @java_class = java_class
      @name_index = name_index
      @value = value
    end
    def name
      @java_class.get_constant_value(@name_index)
    end
    def to_s
      "#{name} = #{value.to_s}"
    end
    def to_bytes
      bytes = to_byte( @name_index, 2)
      bytes += @value.to_bytes()
    end

    attr :name_index, true
    attr :value, true
  end

  #
  #=== アノテーションデータの基底クラス
  #
  class AnnotationElementValue
    include JavaClass::Base
    include JavaClass::Converters

    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*tag::データの種別を示すconstant_poolのインデックス
    #
    def initialize( java_class, tag=nil )
      @java_class = java_class
      @tag = tag
    end
    def to_bytes
      to_byte( @tag, 1)
    end

    attr :tag, true
  end

  #
  #=== 定数のアノテーションデータ
  #
  class ConstAnnotationElementValue < AnnotationElementValue
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*tag::データの種別を示すconstant_poolのインデックス
    #*const_value_index::定数値を示すconstant_poolのインデックス
    #
    def initialize( java_class, tag=nil, const_value_index=nil  )
      super( java_class, tag )
      @const_value_index = const_value_index
    end
    def value
      @java_class.get_constant_value(@const_value_index)
    end
    def to_s
      @java_class.get_constant_as_string(@const_value_index)
    end
    def to_bytes
      bytes = super
      bytes += to_byte( @const_value_index, 2)
    end
    # 定数値を示すconstant_poolのインデックス
    attr :const_value_index, true
  end

  #
  #=== 列挙型のアノテーションデータ
  #
  class EnumAnnotationElementValue < AnnotationElementValue
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*tag::データの種別を示すconstant_poolのインデックス
    #*type_name_index::列挙型の型名を示すconstant_poolのインデックス
    #*const_name_index::列挙型の定数名を示すconstant_poolのインデックス
    #
    def initialize( java_class, tag=nil, type_name_index=nil, const_name_index=nil  )
      super( java_class, tag )
      @type_name_index = type_name_index
      @const_name_index = const_name_index
    end
    def type_name
      @java_class.get_constant_value(@type_name_index)
    end
    def const_name
      @java_class.get_constant_value(@const_name_index)
    end
    def to_s
      convert_field_descriptor(type_name) << "." << const_name.to_s
    end
    def to_bytes
      bytes = super
      bytes += to_byte( @type_name_index, 2)
      bytes += to_byte( @const_name_index, 2)
    end

    attr :type_name_index, true
    attr :const_name_index, true
  end

  #
  #=== クラス型のアノテーションデータ
  #
  class ClassAnnotationElementValue < AnnotationElementValue
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*tag::データの種別を示すconstant_poolのインデックス
    #*class_info_index::クラスを示すconstant_poolのインデックス
    #
    def initialize( java_class, tag=nil, class_info_index=nil  )
      super( java_class, tag )
      @class_info_index = class_info_index
    end
    def class_info
      @java_class.get_constant_value(@class_info_index)
    end
    def to_s
      convert_field_descriptor(class_info) << ".class"
    end
    def to_bytes
      bytes = super
      bytes += to_byte( @class_info_index, 2)
    end

    attr :class_info_index, true
  end

  #
  #=== アノテーション型のアノテーションデータ
  #
  class AnnotationAnnotationElementValue < AnnotationElementValue
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*tag::データの種別を示すconstant_poolのインデックス
    #*annotation::アノテーション
    #
    def initialize( java_class, tag=nil, annotation=nil  )
      super( java_class, tag )
      @annotation = annotation
    end
    def to_s
      @annotation.to_s
    end
    def to_bytes
      bytes = super
      bytes += annotation.to_bytes()
    end

    attr :annotation, true
  end

  #
  #=== 配列型のアノテーションデータ
  #
  class ArrayAnnotationElementValue < AnnotationElementValue
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*tag::データの種別を示すconstant_poolのインデックス
    #*array::配列
    #
    def initialize( java_class, tag=nil, array=[]  )
      super( java_class, tag )
      @array = array
    end
    def to_s
      "[" << @array.map{|a| a.to_s }.join(",") << "]"
    end
    def to_bytes
      bytes = super
      bytes += to_byte( @array.length, 2 )
      @array.each {|a|
        bytes += a.to_bytes()
      }
      return bytes
    end

    attr :array, true
  end

  #
  #=== 引数のアノテーション属性
  #
  class ParameterAnnotationsAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*parameter_annotations::パラメータ番号に対応するアノテーションの配列の配列
    #                        (0番目のパラメータのアノテーションは0番目の配列に格納される。)
    #
    def initialize( java_class, name_index, parameter_annotations=[])
      super( java_class, name_index )
      @parameter_annotations = parameter_annotations
    end

    #
    #=== 引数のindexに対応するアノテーションの配列を取得する。
    #*index::引数の位置を示すインデックス
    #<b>戻り値</b>::引数に設定されたアノテーションの配列
    #
    def [](index)
      @parameter_annotations[index] != nil ? @parameter_annotations[index] : [] 
    end
    #
    #=== 引数のindexに対応するアノテーションの配列を設定する。
    #*index::引数の位置を示すインデックス
    #*annotations::引数に設定するアノテーションの配列
    #
    def []=(index,annotations)
      @parameter_annotations[index] = annotations
    end
    def to_bytes
      bytes = super
      body = to_byte( @parameter_annotations.length, 1)
      @parameter_annotations.each {|annotations|
        body += to_byte( annotations != nil ? annotations.length : 0, 2)
        if ( annotations != nil )
          annotations.each {|a|
            body += a.to_bytes()
          }
        end
      }
      bytes += to_byte( body.length, 4)
      bytes += body
    end

    attr :parameter_annotations, true
  end

  #
  #=== アノテーションの初期値属性
  #
  class AnnotationDefaultAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*element_value::アノテーションの初期値
    #
    def initialize( java_class, name_index, element_value=nil )
      super( java_class, name_index)
      @element_value = element_value
    end
    def to_s
      "default " << @element_value.to_s
    end
    def to_bytes
      bytes = super
      body = element_value.to_bytes()
      bytes += to_byte( body.length, 4)
      bytes += body
    end

    attr :element_value, true
  end

  #
  #=== コード属性
  #
  class CodeAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*max_stack::オペランドスタックの最大深度
    #*max_locals::ローカル変数の数
    #*codes::コード
    #*exception_table::例外
    #*attributes::属性
    #
    def initialize( java_class, name_index, max_stack=nil, \
      max_locals=nil, codes=[], exception_table=[], attributes={} )
      super( java_class, name_index)
      @max_stack = max_stack
      @max_locals = max_locals
      @codes = codes
      @exception_table = exception_table
      @attributes = attributes
    end
    def to_s
      # TODO
    end
    def to_bytes
      bytes = super

      body = to_byte( @max_stack, 2)
      body += to_byte( @max_locals, 2)
      
      tmp = []
      @codes.each {|c|
        tmp += c.to_bytes
      }
      body += to_byte( tmp.length, 4)
      body += tmp
      
      body += to_byte( @exception_table.length, 2)
      @exception_table.each {|ex|
        body += ex.to_bytes()
      }
      body += to_byte( @attributes.length, 2)
      @attributes.each {|k,a|
        body += a.to_bytes()
      }
      bytes += to_byte( body.length, 4)
      bytes += body
    end

    attr :max_stack, true
    attr :max_locals, true
    attr :codes, true
    attr :exception_table, true
    attr :attributes, true
  end
  #
  #=== 例外
  #
  class Excpetion
    include JavaClass::Base
        
    def initialize( java_class, start_pc=nil, end_pc=nil, handler_pc=nil, catch_type_index=nil )
      @java_class=java_class
      @start_pc=start_pc
      @end_pc=end_pc
      @handler_pc=handler_pc
      @catch_type_index=catch_type_index
    end
    def catch_type
      @catch_type_index == nil ? nil : @java_class.get_constant(@catch_type_index)
    end
    def to_bytes
      bytes = []
      bytes += to_byte( @start_pc, 2 )
      bytes += to_byte( @end_pc, 2 )
      bytes += to_byte( @handler_pc, 2 )
      bytes += to_byte( @catch_type_index, 2 )
    end
    attr :start_pc, true
    attr :end_pc, true
    attr :handler_pc, true
    attr :catch_type_index, true
  end

  #
  #=== 行番号属性
  #
  class LineNumberTableAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #
    def initialize( java_class, name_index, line_numbers=[] )
      super( java_class, name_index)
      @line_numbers = line_numbers
    end
    #
    #=== start_pcに対応する位置の行番号オブジェクトがあればそれを返す。
    #*start_pc::コードの番号
    #<b>戻り値</b>::start_pcに対応する位置のソースの行番号オブジェクト。見つからなければnil
    #
    def line_number( start_pc )
      return @line_numbers.find {|l|
        l.start_pc == start_pc
      }
    end
    def to_bytes
      bytes = super
      body = to_byte( @line_numbers.length, 2 )
      @line_numbers.each {|l|
        body += l.to_bytes()
      }
      bytes += to_byte( body.length, 4 )
      bytes += body
    end
    attr :line_numbers, true
  end

  #
  #=== 行番号
  #
  class LineNumber
    include JavaClass::Base
    def initialize( java_class, start_pc=nil, line_number=nil )
      @java_class=java_class
      @start_pc=start_pc
      @line_number=line_number
    end
    def to_s
      "line : #{@line_number}"
    end
    def to_bytes
      bytes = to_byte( @start_pc, 2 )
      bytes += to_byte( @line_number, 2 )
    end
    attr :start_pc, true
    attr :line_number, true
  end

  #
  #=== ローカル変数テーブル属性
  #
  class LocalVariableTableAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*local_variable_table::ローカル変数テーブル
    #
    def initialize( java_class, name_index, local_variable_table=[] )
      super( java_class, name_index)
      @local_variable_table = local_variable_table
    end
    #
    #=== indexに対応するローカル変数情報を取得します。
    #*index::ローカル変数名
    #<b>戻り値</b>::名前に対応するローカル変数情報。見つからなければnil
    #
    def find_by_index( index )
      return @local_variable_table.find {|l|
        l.index == index
      }
    end
    def to_bytes
      bytes = super
      body = to_byte( @local_variable_table.length, 2 )
      @local_variable_table.each {|l|
        body += l.to_bytes()
      }
      bytes += to_byte( body.length, 4 )
      bytes += body
    end
    attr :local_variable_table, true
  end

  #
  #=== ローカル変数
  #
  class LocalVariable
    include JavaClass::Base
    include JavaClass::Converters
    def initialize( java_class, start_pc=nil, \
      length=nil, name_index=nil, descriptor_index=nil, index=nil )
      @java_class=java_class
      @start_pc = start_pc
      @length = length
      @name_index = name_index
      @descriptor_index = descriptor_index
      @index = index
    end
    def to_s
      "#{convert_field_descriptor(descriptor)} #{name}"
    end
    def name
      @java_class.get_constant_value( @name_index )
    end
    def descriptor
      @java_class.get_constant_value( @descriptor_index )
    end
    def to_bytes
      bytes =  to_byte( @start_pc, 2 )
      bytes += to_byte( @length, 2 )
      bytes += to_byte( @name_index, 2 )
      bytes += to_byte( @descriptor_index, 2 )
      bytes += to_byte( @index, 2 )
    end
    attr :start_pc, true
    attr :length, true
    attr :name_index, true
    attr :descriptor_index, true
    attr :index, true
  end
  #
  #=== ローカル変数の型テーブル属性
  #
  class LocalVariableTypeTableAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*local_variable_table::ローカル変数型テーブル
    #
    def initialize( java_class, name_index, local_variable_type_table=[] )
      super( java_class, name_index)
      @local_variable_type_table = local_variable_type_table
    end
    #
    #=== indexに対応するローカル変数型情報を取得します。
    #*index::ローカル変数名
    #<b>戻り値</b>::名前に対応するローカル変数型情報。見つからなければnil
    #
    def find_by_index( index )
      return @local_variable_type_table.find {|l|
        l.index == index
      }
    end
    def to_bytes
      bytes = super
      body = to_byte( @local_variable_type_table.length, 2 )
      @local_variable_type_table.each {|l|
        body += l.to_bytes()
      }
      bytes += to_byte( body.length, 4 )
      bytes += body
    end
    attr :local_variable_type_table, true
  end

  #
  #=== ローカル変数の型
  #
  class LocalVariableType
    include JavaClass::Base
    def initialize( java_class, start_pc=nil, \
      length=nil, name_index=nil, signature_index=nil, index=nil )
      @java_class=java_class
      @start_pc = start_pc
      @length = length
      @name_index = name_index
      @signature_index = signature_index
      @index = index
    end
    def to_s
      # TODO
    end
    def name
      @java_class.get_constant_value( @name_index )
    end
    def signature
      @java_class.get_constant_value( @signature_index )
    end
    def to_bytes
      bytes = to_byte( @start_pc, 2 )
      bytes += to_byte( @length, 2 )
      bytes += to_byte( @name_index, 2 )
      bytes += to_byte( @signature_index, 2 )
      bytes += to_byte( @index, 2 )
    end
    attr :start_pc, true
    attr :length, true
    attr :name_index, true
    attr :signature_index, true
    attr :index, true
  end
  
  #
  #=== スタックマップテーブル属性
  #
  class StackMapTableAttribute < Attribute
    #
    #===コンストラクタ
    #
    #*java_class::属性の所有者であるJavaクラス
    #*name_index::名前を示すconstant_poolのインデックス
    #*stack_map_frame_entries::スタックマップフレームエントリ
    #
    def initialize( java_class, name_index, stack_map_frame_entries=[] )
      super( java_class, name_index)
      @stack_map_frame_entries = stack_map_frame_entries
    end
    def to_bytes
      bytes = super
      body = to_byte( @stack_map_frame_entries.length, 2 )
      @stack_map_frame_entries.each {|e|
        body += e.to_bytes()
      }
      bytes += to_byte( body.length, 4 )
      bytes += body
    end
    attr :stack_map_frame_entries, true
  end
  
  #
  #=== スタックマップフレーム
  #
  class StackMapFrame
    include JavaClass::Base
    #
    #===コンストラクタ
    #
    #*frame_type::種別
    #
    def initialize(frame_type)
      @frame_type = frame_type
    end
    def to_bytes
      to_byte( frame_type, 1 )
    end
    #種別
    attr :frame_type, true
  end
  
  #
  #=== same_frame
  #
  class SameFrame < StackMapFrame
  end

  #
  #=== same_locals_1_stack_item_frame
  #
  class SameLocals1StackItemFrame < StackMapFrame
    #
    #===コンストラクタ
    #
    #*frame_type::種別
    #*verification_type_info:: 型情報
    #
    def initialize(frame_type, verification_type_info=[])
      super(frame_type)
      @verification_type_info = verification_type_info
    end
    def to_bytes
      bytes = super
      verification_type_info.each {|v|
        bytes += v.to_bytes 
      }
      bytes
    end
    #型情報
    attr :verification_type_info, true
  end

  #
  #=== same_locals_1_stack_item_frame_extended
  #
  class SameLocals1StackItemFrameExtended < StackMapFrame
    #
    #===コンストラクタ
    #
    #*frame_type::種別
    #*offset_delta:: オフセットデルタ
    #*verification_type_info:: 型情報
    #
    def initialize(frame_type, offset_delta, verification_type_info=[])
      super(frame_type)
      @offset_delta = offset_delta
      @verification_type_info = verification_type_info
    end
    def to_bytes
      bytes = super
      bytes += to_byte( offset_delta, 2 )
      verification_type_info.each {|v|
        bytes += v.to_bytes 
      }
      bytes
    end
    #オフセットデルタ
    attr :offset_delta, true
    #型情報
    attr :verification_type_info, true
  end
  
  #
  #=== chop_frame
  #
  class ChopFrame < StackMapFrame
    #
    #===コンストラクタ
    #
    #*frame_type::種別
    #*offset_delta:: オフセットデルタ
    #
    def initialize(frame_type, offset_delta)
      super(frame_type)
      @offset_delta = offset_delta
    end
    def to_bytes
      bytes = super
      bytes += to_byte( offset_delta, 2 )
      bytes
    end
    #オフセットデルタ
    attr :offset_delta, true
  end
  
  #
  #=== same_frame_extended
  #
  class SameFrameExtended < StackMapFrame
    
    #
    #===コンストラクタ
    #
    #*frame_type::種別
    #*offset_delta:: オフセットデルタ
    #
    def initialize(frame_type, offset_delta)
      super(frame_type)
      @offset_delta = offset_delta
    end
    def to_bytes
      bytes = super
      bytes += to_byte( offset_delta, 2 )
      bytes
    end
    #オフセットデルタ
    attr :offset_delta, true
  end
  
  #
  #=== append_frame
  #
  class AppendFrame < StackMapFrame
    #
    #===コンストラクタ
    #
    #*frame_type::種別
    #*offset_delta:: オフセットデルタ
    #*verification_type_info:: 型情報
    #
    def initialize(frame_type, offset_delta, verification_type_info=[])
      super(frame_type)
      @offset_delta = offset_delta
      @verification_type_info = verification_type_info
    end
    def to_bytes
      bytes = super
      bytes += to_byte( offset_delta, 2 )
      verification_type_info.each {|v|
        bytes += v.to_bytes 
      }
      bytes
    end
    #オフセットデルタ
    attr :offset_delta, true
    #型情報
    attr :verification_type_info, true
  end
  
  #
  #=== full_frame
  #
  class FullFrame < StackMapFrame
    #
    #===コンストラクタ
    #
    #*frame_type::種別
    #*offset_delta:: オフセットデルタ
    #*verification_type_info:: 型情報
    #
    def initialize(frame_type, offset_delta, 
      verification_type_info_local=[], verification_type_info_stack=[])
      super(frame_type)
      @offset_delta = offset_delta
      @verification_type_info_local = verification_type_info_local
      @verification_type_info_stack = verification_type_info_stack
    end
    def to_bytes
      bytes = super
      bytes += to_byte( offset_delta, 2 )
      [verification_type_info_local, verification_type_info_stack].each {|vi|
        bytes += to_byte( vi.length, 2 )
        vi.each {|v|
          bytes += v.to_bytes 
        }
      }
      bytes
    end
    #オフセットデルタ
    attr :offset_delta, true
    #ローカルの型情報
    attr :verification_type_info_local, true
    #スタックの型情報
    attr :verification_type_info_stack, true
  end
  
  #
  #=== 変数情報(Object_variable_info,Uninitialized_variable_info以外)
  #
  class VariableInfo
    include JavaClass::Base
    #
    #===コンストラクタ
    #
    #*tag::タグ
    #
    def initialize(tag)
      @tag = tag
    end
    def to_bytes
      to_byte( tag, 1 )
    end
    #タグ
    attr :tag, true
  end
  
  #
  #=== 変数情報(Object_variable_info)
  #
  class ObjectVariableInfo < VariableInfo
    include JavaClass::Base
    #
    #===コンストラクタ
    #
    #*tag::タグ
    #*cpool_index:: cpool_index
    #
    def initialize(tag,cpool_index)
      super(tag)
      @cpool_index = cpool_index
    end
    def to_bytes
      super + to_byte( cpool_index, 2 )
    end
    #cpool_index
    attr :cpool_index, true
  end
   
   #
  #=== 変数情報(Uninitialized_variable_info)
  #
  class UninitializedVariableInfo < VariableInfo
    include JavaClass::Base
    #
    #===コンストラクタ
    #
    #*tag::タグ
    #*offset:: オフセット
    #
    def initialize(tag,offset)
      super(tag)
      @offset = offset
    end
    def to_bytes
      super + to_byte( offset, 2 )
    end
    #オフセット
    attr :offset, true
  end
  
end