package com.java34;

public class Breaketball_Coach extends Coach{
    public Breaketball_Coach() {
        super();
        System.out.println("空参调用");
    }

    public Breaketball_Coach(String Name, int Age) {
        super(Name , Age);
    }
    @Override
    public void Teaching() {
        System.out.println("教打篮球");
    }
}
