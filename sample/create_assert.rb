

$: << "../lib"

require "javaclass"
require "kconv"
require "erb"


PATH = 'aaa'

def create( file )
  erb = ERB.new(IO.read("./assert.erb"), nil, "%" )
  open( PATH + "/" + file, "r+b" ) {|io|
    jc = JavaClass.from io
    puts erb.result(binding).tosjis
  }
end

Dir.foreach( PATH.gsub(/\\/, "/") ) {|f| 
  create( f ) if f =~ /\.class$/ && !( f =~ /\$[0-9]+\.class$/ )
}

=begin
% name = jc.this_class.name
    /**
     * {@link <%= name.gsub(/\$/, ".") %>} が同一であることを評価する。
     *
     * @param expected 期待値
     * @param actual 実際の値
     */
    public static final void assertEquals( 
        <%= name.gsub(/\$/, ".") %> expected, 
        <%= name.gsub(/\$/, ".") %> actual ) {
% jc.methods.each { |m|
%   if m.name =~ /^get([A-Z][0-9a-zA-Z\_]+)/ || m.name =~ /^is([A-Z][0-9a-zA-Z\_])+/
%     sname = $1
%     prefix = m.attributes.key?('Deprecated') ? "//" : "" 
%     d = m.convert_method_descriptor( m.descriptor )
%     next if d[:args].length > 0
%     if d[:return] =~ /List/
<%= prefix %>        <%= d[:return] %> actual<%= sname%> = actual.<%= m.name %>();
<%= prefix %>        <%= d[:return] %> expected<%= sname%> = expected.<%= m.name %>();
<%= prefix %>        if ( expected<%= sname%> != null ) {
<%= prefix %>            assertEquals( actual<%= sname%>.size(), expected<%= sname%>.size() );
<%= prefix %>            for ( int i = 0; i < expected<%= sname%>.size(); i++ ) {
<%= prefix %>                assertEquals( expected<%= sname%>.get(i), actual<%= sname%>.get(i) );
<%= prefix %>            }
<%= prefix %>        } else {
<%= prefix %>            assertEquals( actual<%= sname%>, expected<%= sname%> );
<%= prefix %>        }
%     elsif d[:return] =~ /.*\[\]/
<%= prefix %>        <%= d[:return] %>  actual<%= sname%> = actual.<%= m.name %>();
<%= prefix %>        <%= d[:return] %>  expected<%= sname%> = expected.<%= m.name %>();
<%= prefix %>        if ( expected<%= sname%> != null ) {
<%= prefix %>            assertEquals( actual<%= sname%>.length, expected<%= sname%>.length );
<%= prefix %>            for ( int i = 0; i < expected<%= sname%>.length; i++ ) {
<%= prefix %>                assertEquals( expected<%= sname%>[i], actual<%= sname%>[i] );
<%= prefix %>            }
<%= prefix %>        } else {
<%= prefix %>            assertEquals( actual<%= sname%>, expected<%= sname%> );
<%= prefix %>        }
%     else
<%= prefix %>        assertEquals( expected.<%= m.name %>(), actual.<%= m.name %>() );
%     end
%   end
% } 
    }
=end