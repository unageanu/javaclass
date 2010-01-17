package com.example.caller;

public class A {
    public void aaa() {
        aaa2();
        new B().bbb();
        C.ccc();
    }
    void aaa2() {
        aaa3();
    }
    private void aaa3() {
        new D().ddd();
    }
    void aaa4() {
        aaa3();
        aaa4();
    }
}
