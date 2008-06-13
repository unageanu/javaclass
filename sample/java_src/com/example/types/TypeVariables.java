package com.example.types;

import java.util.List;
import java.util.Set;

public class TypeVariables<T> {

    private List<T> list;
    private List<String> list2;
    private List<? extends String>[] list3;

    public <S, U extends T> S foo( List<U> args ) {
        return null;
    }

    public <U extends Object & List & Set > U var( List<U> args ) {
        return null;
    }
}
