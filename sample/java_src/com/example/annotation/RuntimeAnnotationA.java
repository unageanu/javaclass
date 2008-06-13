package com.example.annotation;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.util.List;

@Retention( RetentionPolicy.RUNTIME )
public @interface RuntimeAnnotationA {
    String string();
    String[] stringArray();
    int integer();
    boolean bool();
    java.lang.Class<? extends List> type();
    Thread.State state();
}
