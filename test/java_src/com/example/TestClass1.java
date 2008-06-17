package com.example;

import java.io.Closeable;
import java.io.IOException;
import java.io.Serializable;
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
}
