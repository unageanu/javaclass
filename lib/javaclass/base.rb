
module JavaClass

  module Base

    # 0..255の数字の配列に変換する
    def to_byte( value, length )
      return [0x00]*length if value == nil
      tmp = []
      length.times {|i|
        tmp.unshift( value & 0xFF )
        value >>= 8
      }
      return tmp
    end

    # 16進数表現の文字列形式に変換する
    def dump()
      buff = ""
      i = 1
      self.to_bytes().each {|b|
        buff << sprintf("%0.2X", b)
        buff << (i%16==0 ? "\n" : i%4==0 ? " " : "")
        i+=1
      }
      return buff.strip
    end

    # オブジェクト比較メソッド
    def ==(other)
      _eql?(other) { |a,b| a == b }
    end
    def ===(other)
      _eql?(other) { |a,b| a === b }
    end
    def eql?(other)
      _eql?(other) { |a,b| a.eql? b }
    end
    def hash
      hash = 0
      values.each {|v|
        hash = v.hash + 31 * hash
      }
      return hash
    end
  protected
    def values
      values = []
      values << self.class
      instance_variables.each { |name|
        values << instance_variable_get(name)
      }
      return values
    end
  private
    def _eql?(other, &block)
      return false if other == nil
      return false unless other.kind_of?(JavaClass::Base)
      a = values
      b = other.values
      return false if a.length != b.length
      a.length.times{|i|
        return false unless block.call( a[i], b[i] )
      }
      return true
    end

  end
  
  module Item
    #
    #===シグネチャを取得する。
    #
    #<b>戻り値</b>::シグネチャ。定義されていない場合nil
    #
    def signature
      (attributes.key? "Signature") ? attributes["Signature"].signature : nil
    end

    #
    #===Deprecatedかどうか評価する。
    #
    #<b>戻り値</b>::Deprecatedであればtrue
    #
    def deprecated?
      attributes.key? 'Deprecated'
    end

    #
    #===設定されているアノテーションを配列で取得する。
    #
    #<b>戻り値</b>::アノテーションの配列
    #
    def annotations
      ['RuntimeVisibleAnnotations', 'RuntimeInvisibleAnnotations'].inject([]) { |l, k|
          l.concat( attributes[k].annotations ) if attributes.key? k
          l
      }
    end
  end
  
  
  
  module Converters
  
  module_function
    def convert_field_descriptor( descriptor )
      value = ""
      case descriptor[0].chr
        when "["
          value = convert_field_descriptor( descriptor[1..descriptor.size-1] ) + "[]"
        when "L"
          value = descriptor[1..descriptor.size-2].gsub(/\//, ".")
        when "B"
          value = "byte"
        when "C"
          value = "char"
        when "D"
          value = "double"
        when "F"
          value = "float"
        when "I"
          value = "int"
        when "J"
          value = "long"
        when "S"
          value = "short"
        when "Z"
          value = "boolean"
      end
      return value
    end
    def convert_method_descriptor( descriptor )
      res = {}
      if ( descriptor =~ /\((.*)\)(.+)/ )
        res[:return] = $2 == "V" ? "void" : convert_field_descriptor( $2 )
        res[:args] = []
        strs = $1.scan( /(\[*[BCDFIJSZ]|\[*L.*?;)/ ).flatten
        strs.each { |str|
          res[:args] << convert_field_descriptor( str )
        }
      else
        raise "illegal method descriptor. descriptor=" << descriptor
      end
      return res
    end
    #
    #=== コードの文字列表現を得る。
    #*code::コード
    #<b>戻り値</b>::コードの文字列表現
    #
    def convert_code( code )
      str = nil
      case code
      when 0x00; str = "nop"
      when 0x01; str = "aconst_null"
      when 0x02; str = "iconst_m1"
      when 0x03; str = "iconst_0"
      when 0x04; str = "iconst_1"
      when 0x05; str = "iconst_2"
      when 0x06; str = "iconst_3"
      when 0x07; str = "iconst_4"
      when 0x08; str = "iconst_5"
      when 0x09; str = "lconst_0"
      when 0x0a; str = "lconst_1"
      when 0x0b; str = "fconst_0"
      when 0x0c; str = "fconst_1"
      when 0x0d; str = "fconst_2"
      when 0x0e; str = "dconst_0"
      when 0x0f; str = "dconst_1"
      when 0x10; str = "bipush"
      when 0x11; str = "sipush"
      when 0x12; str = "ldc"
      when 0x13; str = "ldc_w"
      when 0x14; str = "ldc2_w"
      when 0x15; str = "iload"
      when 0x16; str = "lload"
      when 0x17; str = "fload"
      when 0x18; str = "dload"
      when 0x19; str = "aload"
      when 0x1a; str = "iload_0"
      when 0x1b; str = "iload_1"
      when 0x1c; str = "iload_2"
      when 0x1d; str = "iload_3"
      when 0x1e; str = "lload_0"
      when 0x1f; str = "lload_1"
      when 0x20; str = "lload_2"
      when 0x21; str = "lload_3"
      when 0x22; str = "fload_0"
      when 0x23; str = "fload_1"
      when 0x24; str = "fload_2"
      when 0x25; str = "fload_3"
      when 0x26; str = "dload_0"
      when 0x27; str = "dload_1"
      when 0x28; str = "dload_2"
      when 0x29; str = "dload_3"
      when 0x2a; str = "aload_0"
      when 0x2b; str = "aload_1"
      when 0x2c; str = "aload_2"
      when 0x2d; str = "aload_3"
      when 0x2e; str = "iaload"
      when 0x2f; str = "laload"
      when 0x30; str = "faload"
      when 0x31; str = "daload"
      when 0x32; str = "aaload"
      when 0x33; str = "baload"
      when 0x34; str = "caload"
      when 0x35; str = "saload"
      when 0x36; str = "istore"
      when 0x37; str = "lstore"
      when 0x38; str = "fstore"
      when 0x39; str = "dstore"
      when 0x3a; str = "astore"
      when 0x3b; str = "istore_0"
      when 0x3c; str = "istore_1"
      when 0x3d; str = "istore_2"
      when 0x3e; str = "istore_3"
      when 0x3f; str = "lstore_0"
      when 0x40; str = "lstore_1"
      when 0x41; str = "lstore_2"
      when 0x42; str = "lstore_3"
      when 0x43; str = "fstore_0"
      when 0x44; str = "fstore_1"
      when 0x45; str = "fstore_2"
      when 0x46; str = "fstore_3"
      when 0x47; str = "dstore_0"
      when 0x48; str = "dstore_1"
      when 0x49; str = "dstore_2"
      when 0x4a; str = "dstore_3"
      when 0x4b; str = "astore_0"
      when 0x4c; str = "astore_1"
      when 0x4d; str = "astore_2"
      when 0x4e; str = "astore_3"
      when 0x4f; str = "iastore"
      when 0x50; str = "lastore"
      when 0x51; str = "fastore"
      when 0x52; str = "dastore"
      when 0x53; str = "aastore"
      when 0x54; str = "bastore"
      when 0x55; str = "castore"
      when 0x56; str = "sastore"
      when 0x57; str = "pop"
      when 0x58; str = "pop2"
      when 0x59; str = "dup"
      when 0x5a; str = "dup_x1"
      when 0x5b; str = "dup_x2"
      when 0x5c; str = "dup2"
      when 0x5d; str = "dup2_x1"
      when 0x5e; str = "dup2_x2"
      when 0x5f; str = "swap"
      when 0x60; str = "iadd"
      when 0x61; str = "ladd"
      when 0x62; str = "fadd"
      when 0x63; str = "dadd"
      when 0x64; str = "isub"
      when 0x65; str = "lsub"
      when 0x66; str = "fsub"
      when 0x67; str = "dsub"
      when 0x68; str = "imul"
      when 0x69; str = "lmul"
      when 0x6a; str = "fmul"
      when 0x6b; str = "dmul"
      when 0x6c; str = "idiv"
      when 0x6d; str = "ldiv"
      when 0x6e; str = "fdiv"
      when 0x6f; str = "ddiv"
      when 0x70; str = "irem"
      when 0x71; str = "lrem"
      when 0x72; str = "frem"
      when 0x73; str = "drem"
      when 0x75; str = "lneg"
      when 0x76; str = "fneg"
      when 0x77; str = "dneg"
      when 0x78; str = "ishl"
      when 0x79; str = "lshl"
      when 0x7a; str = "ishr"
      when 0x7b; str = "lshr"
      when 0x7c; str = "iushr"
      when 0x7d; str = "lushr"
      when 0x7e; str = "iand"
      when 0x7f; str = "land"
      when 0x80; str = "ior"
      when 0x81; str = "lor"
      when 0x82; str = "ixor"
      when 0x83; str = "lxor"
      when 0x84; str = "iinc"
      when 0x85; str = "i2l"
      when 0x86; str = "i2f"
      when 0x87; str = "i2d"
      when 0x88; str = "l2i"
      when 0x89; str = "l2f"
      when 0x8a; str = "l2d"
      when 0x8b; str = "f2i"
      when 0x8c; str = "f2l"
      when 0x8d; str = "f2d"
      when 0x8e; str = "d2i"
      when 0x8f; str = "d2l"
      when 0x90; str = "d2f"
      when 0x91; str = "i2b"
      when 0x92; str = "i2c"
      when 0x93; str = "i2s"
      when 0x94; str = "lcmp"
      when 0x95; str = "fcmpl"
      when 0x96; str = "fcmpg"
      when 0x97; str = "dcmpl"
      when 0x98; str = "dcmpg"
      when 0x99; str = "ifeq"
      when 0x9a; str = "ifne"
      when 0x9b; str = "iflt"
      when 0x9c; str = "ifge"
      when 0x9d; str = "ifgt"
      when 0x9e; str = "ifle"
      when 0x9f; str = "if_icmpeq"
      when 0xa0; str = "if_icmpne"
      when 0xa1; str = "if_icmplt"
      when 0xa2; str = "if_icmpge"
      when 0xa3; str = "if_icmpgt"
      when 0xa4; str = "if_icmple"
      when 0xa5; str = "if_acmpeq"
      when 0xa6; str = "if_acmpne"
      when 0xa7; str = "goto"
      when 0xa8; str = "jsr"
      when 0xa9; str = "ret"
      when 0xaa; str = "tableswitch"
      when 0xab; str = "lookupswitch"
      when 0xac; str = "ireturn"
      when 0xad; str = "lreturn"
      when 0xae; str = "freturn"
      when 0xaf; str = "dreturn"
      when 0xb0; str = "areturn"
      when 0xb1; str = "return"
      when 0xb2; str = "getstatic"
      when 0xb3; str = "putstatic"
      when 0xb4; str = "getfield"
      when 0xb5; str = "putfield"
      when 0xb6; str = "invokevirtual"
      when 0xb7; str = "invokespecial"
      when 0xb8; str = "invokestatic"
      when 0xb9; str = "invokeinterface"
      when 0xba; str = "xxxunusedxxx1"
      when 0xbb; str = "new"
      when 0xbc; str = "newarray"
      when 0xbd; str = "anewarray"
      when 0xbe; str = "arraylength"
      when 0xbf; str = "athrow"
      when 0xc0; str = "checkcast"
      when 0xc1; str = "instanceof"
      when 0xc2; str = "monitorenter"
      when 0xc3; str = "monitorexit"
      when 0xc4; str = "wide"
      when 0xc5; str = "multianewarray"
      when 0xc6; str = "ifnull"
      when 0xc7; str = "ifnonnull"
      when 0xc8; str = "goto_w"
      when 0xc9; str = "jsr_w"
      when 0xca; str = "breakpoint"
      when 0xfe; str = "impdep1"
      when 0xff; str = "impdep2"
      else
        aise "unkown code. code=" << code.to_s
      end
      return str;
    end
  
  end

end