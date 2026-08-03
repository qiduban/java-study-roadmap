package com.java34;

public class Pingpang extends Player implements EngLish {
    public Pingpang(){
        super();
    }

    public Pingpang(String Name , int Age){
        super(Name , Age);
    }
    @Override
    public void English() {
        System.out.println("会说英语");
    }

    @Override
    public void Piaying() {
        System.out.println("学打乒乓球");
    }
}
