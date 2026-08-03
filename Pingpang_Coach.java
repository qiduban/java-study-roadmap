package com.java34;

public class Pingpang_Coach extends Coach implements EngLish{
    public Pingpang_Coach() {
        super();
        System.out.println("空参调用");
    }

    public Pingpang_Coach(String Name, int Age) {
        super(Name , Age);
    }
    @Override
    public void Teaching() {
        System.out.println("教打乒乓球");
    }

    @Override
    public void English() {
        System.out.println("会说英语");
    }
}
