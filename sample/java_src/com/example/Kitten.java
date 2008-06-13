package com.example;

import java.io.Serializable;

/**
 * 猫。
 *
 * @version $Revision:$
 * @author  $Author:$
 */
public class Kitten implements Serializable {

    /**
     * 名前
     */
    private String name = "";

    /**
     * 年齢
     */
    private int age = 0;

    /**
     * コンストラクタ
     */
    public Kitten (){}

    /**
     * コンストラクタ
     *
     * @param name
     *        名前
     * @param age
     *        年齢
     */
    public Kitten (
        String name,
        int age ) {
        this.name = name;
        this.age = age;
    }

    /**
     * 名前を取得する。
     * @return 名前
     */
    public String getName () {
        return name;
    }
    /**
     * 名前を設定する。
     * @param name 名前
     */
    public void setName ( String name ) {
        this.name = name;
    }

    /**
     * 年齢を取得する。
     * @return 年齢
     */
    public int getAge () {
        return age;
    }
    /**
     * 年齢を設定する。
     * @param age 年齢
     */
    public void setAge ( int age ) {
        this.age = age;
    }
    /**
     * 鳴く
     */
    public void meow( ) {
        System.out.println( "meow!" );
    }
}