package com.java34;

public abstract class Coach {
    private String Name;
    public int Age;

    public Coach() {
        System.out.println("空参调用");
    }

    public Coach(String Name, int Age) {
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
    public abstract void Teaching();
}
