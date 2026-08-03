package com.java34;

public abstract class Player{
    private String Name;
    public int Age;

    public Player() {
        System.out.println("空参调用");
    }

    public Player(String Name, int Age) {
        this.Name = Name;
        this.Age = Age;
    }

    public String getName() {
        return Name;
    }

    public void setName(String name) {
        Name = name;
    }

    public int getAge() {
        return Age;
    }

    public void setAge(int age) {
        Age = age;
    }
    public abstract void Piaying();
}