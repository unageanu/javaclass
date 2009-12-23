package com.example.code;

import java.net.URI;
import java.net.URISyntaxException;

public class Statement {
    
    public void basic( int i ) {
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
