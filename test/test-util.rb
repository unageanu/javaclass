
module JavaClass

  module TestUtil 
    # オブジェクトをバイト配列に変換→再読み込みし、同じオブジェクトが作成されることを評価する。
    def assert_to_byte_and_read( obj, assertion, reader )
      assertion.call(obj)
      obj2 = reader.call( ArrayIO.new( obj.to_bytes ) ) 
      assertion.call(obj2)
      assert_equals( obj, obj2 )
    end
  end
  
end