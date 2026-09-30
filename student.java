package com.java48;

import java.io.Serializable;

public class student implements Serializable {//对象要是想实现序列化就必须实现SERIALIZANBLE接口
    String name;
    int age;
    transient int  num;//将变量以transient修饰会导致此变量不参加序列化
    public student(){

    }
    public student(String name, int age, int num) {
        this.name = name;
        this.age = age;
        this.num = num;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public int getNum() {
        return num;
    }

    public void setNum(int num) {
        this.num = num;
    }

    @Override
    public String toString() {
        return "student{" +
                "name='" + name + '\'' +
                ", age=" + age +
                ", num=" + num +
                '}';
    }
}
