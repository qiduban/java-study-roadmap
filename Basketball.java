package com.java34;

public class Basketball extends Player {
    public Basketball(){
        super();
    }

    public Basketball(String Name , int Age){
        super(Name , Age);
    }

    @Override
    public void Piaying() {
        System.out.println("学打篮球");
    }
}
