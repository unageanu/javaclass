package com.example.caller;

public class CallSample {
    static class A {
        void aaa() {
            new B().bbb();
        }
        void aaa2() {
            new C().ccc();
        }
        void aaa3() {
            aaa2();
        }
    }
    static class B {
        void bbb() {
            new C().ccc();
        }
    }
    static class C {
        void ccc() {}
    }
}
