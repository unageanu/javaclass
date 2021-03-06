package com.example;

import java.io.Closeable;
import java.io.IOException;
import java.io.Serializable;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;

public final class TestClass1<T, X extends Runnable> 
extends ArrayList<T> 
implements Serializable, Closeable{
    
    static class Hoo {};
    class Var {};
    Object x = new Object() {}; // 無名クラス
    
    static String stringConstant = "あいう";
    static int intConstant = 1;
    static long longConstant = 100L;
    static List<String> listConstant = new ArrayList<String>();
    static float floatConstant  = 0F;
    static double doubleConstant0 = 0D;
    static byte byteConstant  = 10;
    static char charConstant  = 'a';
    static boolean booleanConstant  = false;
    
    public void close() throws IOException {}
    
    public void statement( int i ) {
        if ( i < 10 ) System.out.println( "a" );
        if ( i > 10 ) {
            System.out.println( "b" );
        } else {
            System.out.println( "c" );
        }
        for ( int j=0;j<10;j++ ) {
            System.out.println( j );
        }
        for ( String str : new String[]{"a","b","c"} ) {
            System.out.println( str );
        }
        int j = 9;
        while ( j-- > 10 ) {
            System.out.println( j );
        }
        switch (i) {
            case 1 : System.out.println( "1" ); break;
            case 2 : System.out.println( "2" );
            default : System.out.println( "3" );
        }
        try {
            new URI( "http://foo" + i );
        } catch ( RuntimeException e ) {
            e.printStackTrace();
        } catch (URISyntaxException e) {
            e.printStackTrace();
        } finally {
            System.out.println( "x" );
        }
    }
}
