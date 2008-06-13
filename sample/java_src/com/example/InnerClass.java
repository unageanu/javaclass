package com.example;


import java.util.Map;

public interface InnerClass {

    // staticなインナークラス
    static class StaticInnerClass {
        // インナークラス内インナークラス
        static class StaticInnerInnerClass{}
        class InnerInnerClass{}
    }

    // インナークラス
    class BasicInnerClass {}

    // 匿名クラス
    Object x = new Object() {
        public String toString() { return "x"; }
    };

}
