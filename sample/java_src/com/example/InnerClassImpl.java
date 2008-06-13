package com.example;


import java.util.Map;


public class InnerClassImpl
implements InnerClass {

    // staticなインナークラス
    static class StaticInnerClass2 {}

    // インナークラス
    class BasicInnerClass2 {}

    // 匿名クラス
    Object xx = new Object() {
        public String toString() { return "xx"; }
    };

    public static void main() {

        // 関数内クラス
        class MethodInnerClass {}

        // 関数内の匿名クラス
        Object yy = new Object() {
            public String toString() { return "yy"; }
        };
    }
}
