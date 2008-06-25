#!/usr/bin/ruby

# jar内のクラスファイルのassertEquals()を生成する。
#
# ./create_assert.rb <jarファイル> [<対象クラスを示す正規表現>]
#

require 'rubygems'
require "javaclass"
require "zip/zip"
require "kconv"
require "erb"


TEMPLATE = <<-ERB
% name = jc.name
    /**
     * {@link <%= name.gsub(/\\$/, ".") %>} が同一であることを評価する。
     *
     * @param expected 期待値
     * @param actual 実際の値
     */
    public static final void assertEquals( 
        <%= name.gsub(/\\$/, ".") %> expected, 
        <%= name.gsub(/\\$/, ".") %> actual ) {
% if jc.super_class != nil && jc.super_class != "java.lang.Object"
%  super_class = jc.super_class.gsub(/\\$/, ".")
        assertEquals( (<%= super_class %>) expected, (<%= super_class %>) actual );
% end   
% jc.methods.each { |m|
%   next if m.deprecated?
%   next if m.access_flag.on? JavaClass::MethodAccessFlag::ACC_STATIC
%   next if m.access_flag.on? JavaClass::MethodAccessFlag::ACC_PRIVATE
%   if m.name =~ /^get(\\S+)/ || m.name =~ /^is(\\S)+/
%     sname = $1
%     d = JavaClass::Converters.convert_method_descriptor( m.descriptor )
%     next if d[:args].length > 0
%     if d[:return] =~ /List$/ || d[:return] =~ /.*\\[\\]/ || d[:return] =~ /Map$/
        <%= d[:return] %> expected<%= sname%> = expected.<%= m.name %>();
        <%= d[:return] %> actual<%= sname%> = actual.<%= m.name %>();
        if ( expected<%= sname%> != null ) {
%       if d[:return] =~ /List$/ 
            assertEquals( expected<%= sname%>.size(), actual<%= sname%>.size() );
            for ( int i = 0; i < expected<%= sname%>.size(); i++ ) {
                assertEquals( expected<%= sname%>.get(i), actual<%= sname%>.get(i) );
            }
%       elsif d[:return] =~ /.*\\[\\]/
            assertEquals( expected<%= sname%>.length, actual<%= sname%>.length );
            for ( int i = 0; i < expected<%= sname%>.length; i++ ) {
                assertEquals( expected<%= sname%>[i], actual<%= sname%>[i] );
            }
%       else
            assertEquals( expected<%= sname%>.size(), actual<%= sname%>.size() );
            for ( Object key : expected<%= sname%>.keySet() ) {
                assertEquals( expected<%= sname%>.get(key), actual<%= sname%>.get(key) );
            }
%       end
        } else {
            assertEquals( expected<%= sname%>, actual<%= sname%> );
        }
%     else
        assertEquals( expected.<%= m.name %>(), actual.<%= m.name %>() );
%     end
%   end
% } 
    }
ERB

# ZipInputStreamにはgetcが実装されていないので、追加する。
module Zip
  class ZipInputStream
    def getc
      read(1)[0]
    end
  end
end

# Zipエントリ内のクラス一覧を列挙して解析する。
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

erb = ERB.new(TEMPLATE, nil, "%" )
r = Regexp.compile(ARGV[1]) if ( ARGV.length > 1 ) 

each_class( ARGV[0] ) {|jc|
  
  next if r != nil && !r.match(jc.name)
    
  # enum, annotationは除外
  next if jc.access_flag.on? JavaClass::ClassAccessFlag::ACC_ENUM
  next if jc.access_flag.on? JavaClass::ClassAccessFlag::ACC_ANNOTATION
  
  # deprecatedなクラスも除外
  next if jc.deprecated?
  puts erb.result(binding).tosjis
}
