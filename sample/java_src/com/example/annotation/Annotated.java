package com.example.annotation;

import java.util.ArrayList;

@RuntimeAnnotationA(
  string      = "aaa",
  stringArray = { "a", "b", "c" },
  bool        = false,
  integer     = 1000,
  state       = Thread.State.BLOCKED,
  type        = ArrayList.class
)
@RuntimeAnnotationB("test")
@SourceAnnotationA("test")
@ClassAnnotationA("test")
public class Annotated {

	@RuntimeAnnotationA(
			  string      = "bbb",
			  stringArray = { "a", "b", "c" },
			  bool        = false,
			  integer     = 1000,
			  state       = Thread.State.BLOCKED,
			  type        = ArrayList.class
			)
	@RuntimeAnnotationB("test")
	@SourceAnnotationA("test")
	@ClassAnnotationA("test")
	public String foo;

    // アノテーション付きメソッド。
    // パラメータもアノテーションを持つ。
	@RuntimeAnnotationA(
			  string      = "ccc",
			  stringArray = { "a", "b", "c" },
			  bool        = false,
			  integer     = 1000,
			  state       = Thread.State.BLOCKED,
			  type        = ArrayList.class
			)
	@RuntimeAnnotationB("test")
	@SourceAnnotationA("test")
	@ClassAnnotationA("test")
	void foo(
        @HasDefaultValue @RuntimeAnnotationB("test") @RuntimeAnnotationC String str,
        @RuntimeAnnotationC @RuntimeAnnotationB("test") int x ) {}
}
