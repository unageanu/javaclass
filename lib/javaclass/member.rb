require "javaclass/base"

module JavaClass

  #
  #=== Field,Methodの基底クラス
  #
  class Member
    include JavaClass::Base
    include JavaClass::Converters
    include JavaClass::Item

    #
    #===コンストラクタ
    #
    #*java_class::メンバーの所有者であるJavaクラス
    #
    def initialize( java_class )
      @java_class = java_class
      @attributes = {}
    end
    #
    #===名前を取得する。
    #
    #<b>戻り値</b>::名前
    #
    def name
      @java_class.get_constant_value(@name_index)
    end
    #
    #===ディスクリプタを取得する。
    #
    #<b>戻り値</b>::ディスクリプタ
    #
    def descriptor
      @java_class.get_constant_value(@descriptor_index)
    end
    def to_bytes()
      bytes = @access_flag.to_bytes()
      bytes += to_byte( @name_index, 2)
      bytes += to_byte( @descriptor_index, 2)
      bytes += to_byte( @attributes.size, 2)
      @attributes.keys.sort!.each {|k| 
        bytes += @attributes[k].to_bytes()
      }
      return bytes
    end
    # JavaClass
    attr :java_class, true
    # アクセスフラグ
    attr :access_flag, true
    # 名前を示すconstant_poolのインデックス
    attr :name_index, true
    # ディスクリプタを示すconstant_poolのインデックス
    attr :descriptor_index, true
    # 属性名をキーとする属性のハッシュ
    attr :attributes, true
  end

  #
  #=== Field
  #
  class Field < Member
    #
    #===コンストラクタ
    #
    #*java_class::Fieldの所有者であるJavaクラス
    #
    def initialize( java_class )
      super( java_class )
    end
    #
    #=== 定数フィールドの初期値を取得する
    #
    #<b>戻り値</b>::定数フィールドの初期値。定数でない場合や初期値が設定されていない場合nil
    #
    def static_value 
      (attributes.key? "ConstantValue") ? attributes["ConstantValue"].value : nil
    end
    def to_s
      str = ""
      str << attributes["Signature"].to_s << "\n" if attributes.key? "Signature"
      str << "// !deprecated!\n" if deprecated?
      str << annotations.inject( "" ){|s, e| s << e.to_s << "\n" } 
      datas = []
      datas << access_flag.to_s if access_flag.to_s.length > 0
      datas << convert_field_descriptor(descriptor)
      datas << name
      str << datas.join(" ")
      str << " = " << attributes["ConstantValue"].to_s if attributes.key? "ConstantValue"
      return str
    end
  end

  #
  #=== Method
  #
  class Method < Member
    #
    #===コンストラクタ
    #
    #*java_class::Methodの所有者であるJavaクラス
    #
    def initialize( java_class )
      super( java_class )
    end
    
    #
    #=== メソッドで発生する例外のクラス名を配列で取得する
    #
    #<b>戻り値</b>::メソッドで発生する例外クラス名の配列
    #
    def exceptions 
      (attributes.key? "Exceptions") ? 
        attributes["Exceptions"].exceptions.map{|i|i.name} : []
    end
    #
    #=== 引数のクラス名を配列で取得する
    #
    #<b>戻り値</b>::引数のクラス名の配列
    #
    def parameters
      convert_method_descriptor( descriptor )[:args]
    end
    #
    #=== メソッドの戻り値クラス名を取得する
    #
    #<b>戻り値</b>::メソッドの戻り値クラス名
    #
    def return_type
      convert_method_descriptor( descriptor )[:return]
    end
    #
    #===指定したパラメータに設定されているアノテーションを配列で取得する。
    #
    #<b>戻り値</b>::アノテーションの配列
    #
    def parameter_annotations(index)
      ['RuntimeVisibleParameterAnnotations', 
       'RuntimeInvisibleParameterAnnotations'].inject([]) { |l, k|
          l.concat( attributes[k][index] ) if attributes.key? k
          l
      }
    end
    
    def to_s
      str = ""
      str << attributes["Signature"].to_s << "\n" if attributes.key? "Signature"
      str << "// !deprecated!\n" if deprecated?
      str << annotations.inject( "" ){|s, e| s << e.to_s << "\n" }
      d = convert_method_descriptor( descriptor )
      i = 0
      args = d[:args].map(){|item|
         a = parameter_annotations(i)
         tmp = a.length > 0 ? a.map(){|a| a.to_s}.join("\n") << " " : ""
         i+=1
         tmp << "#{item} arg#{i}"
      }.join(", ")
      datas = []
      datas << access_flag.to_s if access_flag.to_s.length > 0
      datas << d[:return]
      datas << name
      datas << "("
      datas << args
      datas << ")"
      str << datas.join(" ")
      str << "\n" << attributes["Exceptions"].to_s if attributes.key? "Exceptions"
      if ( attributes.key? "Code")
        str << " {\n"
#        codes = attributes["Code"]
#        local_types = codes.attributes["LocalVariableTypeTable"] if codes.attributes.key? "LocalVariableTypeTable"
#
#        if codes.attributes.key? "LocalVariableTable"
#          codes.attributes["LocalVariableTable"].local_variable_table.each {|l|
#            type = local_types.find_by_index(l.index) if local_types != nil
#            str << "    // signature " << type.signature << "\n" if type != nil
#            str << "    " << convert_field_descriptor(l.descriptor)
#            str << " " << l.name << ";\n"
#          }
#        end
#        str << "\n"
#        lines = codes.attributes["LineNumberTable"] if codes.attributes.key? "LineNumberTable"
#        codes.codes.each_index {|i|
#          str << "    " << convert_code(codes.codes[i])
#          str << " // line : #{lines.line_number(i)}" if lines != nil && lines.line_number(i) != nil
#          str << "\n";
#        }
        str << "}"
      end
      str << " #{attributes['AnnotationDefault'].to_s}" if attributes.key? 'AnnotationDefault'
      return str
    end
  end
end