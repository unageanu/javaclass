require "javaclass/util"

module JavaClass

  #
  #=== Field,Methodの基底クラス
  #
  class Member
    include JavaClass::Util

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
      bytes = @access_flag.to_bytes(bytes)
      bytes += to_byte( @name_index, 2)
      bytes += to_byte( @descriptor_index, 2)
      bytes += to_byte( @attributes.size, 2)
      @attributes.each {|a| 
        bytes += a.to_bytes()
      }
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
    def to_s
      str = ""
      str << "#{attributes['Signature'].to_s}\n" if attributes.key? 'Signature'
      str << "#{attributes['Deprecated'].to_s}\n" if attributes.key? 'Deprecated'
      str << "#{attributes['RuntimeVisibleAnnotations'].to_s}\n" if attributes.key? 'RuntimeVisibleAnnotations'
        str << "#{attributes['RuntimeInvisibleAnnotations'].to_s}\n" if attributes.key? 'RuntimeInvisibleAnnotations'
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
    def to_s
      str = ""
      str << "#{attributes['Signature'].to_s}\n" if attributes.key? 'Signature'
      str << "#{attributes['Deprecated'].to_s}\n" if attributes.key? 'Deprecated'
        str << "#{attributes['RuntimeVisibleAnnotations'].to_s}\n" if attributes.key? 'RuntimeVisibleAnnotations'
        str << "#{attributes['RuntimeInvisibleAnnotations'].to_s}\n" if attributes.key? 'RuntimeInvisibleAnnotations'
      d = convert_method_descriptor( descriptor )
      i = 0
      args = d[:args].map(){|item|
         tmp = ""
         if attributes.key? 'RuntimeVisibleParameterAnnotations'
           annotations = attributes['RuntimeVisibleParameterAnnotations']
             tmp << " " << annotations[i].map(){|a| a.to_s }.join("\n") if ( !annotations[i].empty? && annotations[i] != nil )
         end
         if attributes.key? 'RuntimeInvisibleParameterAnnotations'
           annotations = attributes['RuntimeInvisibleParameterAnnotations']
             tmp << " " << annotations[i].map(){|a| a.to_s }.join("\n")  if ( !annotations[i].empty? && annotations[i] != nil )
         end
         i+=1
         tmp << " #{item} arg#{i}"

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
        str << "{\n"
        codes = attributes["Code"]
        local_types = codes.attributes["LocalVariableTypeTable"] if codes.attributes.key? "LocalVariableTypeTable"

        if codes.attributes.key? "LocalVariableTable"
          codes.attributes["LocalVariableTable"].local_variable_table.each {|l|
            type = local_types.find_by_index(l.index) if local_types != nil
            str << "    // signature " << type.signature << "\n" if type != nil
            str << "    " << convert_field_descriptor(l.descriptor)
            str << " " << l.name << ";\n"
          }
        end
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