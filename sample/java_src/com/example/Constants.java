package com.example;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;


public interface Constants
extends Serializable {

    static final String stringConstant = "あいう";
    static int intConstant = 1;
    static int intConstant2 = -1;
    static int intConstantMax = Integer.MAX_VALUE;
    static int intConstantMin = Integer.MIN_VALUE;
    
    public static long longConstant = 100L;
    public static long longConstant2 = -100L;
    public static long longConstantMax = Long.MAX_VALUE;
    public static long longConstantMin = Long.MIN_VALUE;
    
    public static final List<String> listConstant = new ArrayList<String>();

    float floatConstant0  = 0F;
    float floatConstant  = 16.5F;
    float floatConstant2 = -16.5F;
    float floatConstantNan = Float.NaN;
    float floatConstantMax  = Float.MAX_VALUE;
    float floatConstantMin  = Float.MIN_VALUE;
    float floatConstantNegativeInfinity = Float.NEGATIVE_INFINITY;
    float floatConstantPositiveInfinity = Float.POSITIVE_INFINITY;

    double doubleConstant0  = 0D;
    double doubleConstant  = 16.5D;
    double doubleConstant2 = -16.5D;
    double doubleConstantMax  = Double.MAX_VALUE;
    double doubleConstantMin  = Double.MIN_VALUE;
    double doubleConstantNan = Double.NaN;
    double doubleConstantNegativeInfinity = Double.NEGATIVE_INFINITY;
    double doubleConstantPositiveInfinity = Double.POSITIVE_INFINITY;

    public InnerClass.StaticInnerClass xx
        = new InnerClass.StaticInnerClass();

}
