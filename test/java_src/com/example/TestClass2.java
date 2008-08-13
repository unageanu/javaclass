package com.example;

import java.io.Closeable;
import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public final class TestClass2<T, X extends Runnable> 
extends ArrayList<T> 
implements Serializable {
    
    private String str;
    private int i;
    private boolean bool;
    private long l;
    private List<String> list;
    private LinkedList<String> list2;
    private String[] strs;
    private Map<String, Object> map;
    private HashMap<String, Object> map2;
    
    static class Hoo {};
    Object x = new Object() {}; // 無名クラス
    
    static String stringConstant = "あいう";
    
    private String getPrivate() throws IOException {
        return "";
    }

    public String getStr() {
        return str;
    }

    public void setStr(String str) {
        this.str = str;
    }

    public int getI() {
        return i;
    }

    public void setI(int i) {
        this.i = i;
    }

    public boolean isBool() {
        return bool;
    }

    public void setBool(boolean bool) {
        this.bool = bool;
    }

    public long getL() {
        return l;
    }

    public void setL(long l) {
        this.l = l;
    }

    public List<String> getList() {
        return list;
    }

    public void setList(List<String> list) {
        this.list = list;
    }

    public LinkedList<String> getList2() {
        return list2;
    }

    public void setList2(LinkedList<String> list2) {
        this.list2 = list2;
    }

    public String[] getStrs() {
        return strs;
    }

    public void setStrs(String[] strs) {
        this.strs = strs;
    }

    public Map<String, Object> getMap() {
        return map;
    }

    public void setMap(Map<String, Object> map) {
        this.map = map;
    }

    public HashMap<String, Object> getMap2() {
        return map2;
    }

    public void setMap2(HashMap<String, Object> map2) {
        this.map2 = map2;
    }

    public Object getX() {
        return x;
    }

    public void setX(Object x) {
        this.x = x;
    }

    public static String getStringConstant() {
        return stringConstant;
    }

    public static void setStringConstant(String stringConstant) {
        TestClass2.stringConstant = stringConstant;
    }
}
