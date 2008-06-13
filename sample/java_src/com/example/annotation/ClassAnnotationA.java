package com.example.annotation;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.util.List;

@Retention( RetentionPolicy.CLASS )
public @interface ClassAnnotationA {
    String value();
}
