package com.example.annotation;

import java.util.ArrayList;

public class AnnotatedMethod {


    // アノテーション付きパラメータを持つメソッド。
	void foo(
        @A("test") @B @C String str,
        @B @C int x ) {}

    static @interface A {
        String value();
    }
    static @interface B {}
    static @interface C {}
}
