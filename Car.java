package com.java35;

import jdk.swing.interop.SwingInterOpUtils;

import java.sql.SQLOutput;
import java.util.Scanner;

public class Car {
    Scanner sf =new Scanner(System.in);
    String CarName;
    int CarAge;
    String CarColour;
    int a = 10;
    Engine e =new Engine();
    public Car(){
        System.out.println("空参调用");
    }
    public Car(String CarName , int CarAge , String CarColour){
        this.CarName = CarName;
        this.CarAge = CarAge;
        this.CarColour = CarColour;

        System.out.println("请输入引擎状况");
        e.EngineName = sf.next() ;
        e.EngineAge = sf.nextInt();
    }
    public String getCarName() {
        return CarName;
    }

    public void setCarName(String carName) {
        CarName = carName;
    }

    public int getCarAge() {
        return CarAge;
    }

    public void setCarAge(int carAge) {
        CarAge = carAge;
    }

    public String getCarColour() {
        return CarColour;
    }

    public void setCarColour(String carColour) {
        CarColour = carColour;
    }
    public void show(Car this){
        System.out.println(CarAge);
        System.out.println(CarName);
        System.out.println(CarColour);
        e.show();
    }

    class Engine{
        int a= 20;
        String EngineName;
        int EngineAge;
        public Engine(){
            System.out.println("空参调用");
        }
        public Engine(String EngineName, int EngineAge){
            this.EngineName = EngineName;
            this.EngineAge = EngineAge;
        }
        public void show(){
            System.out.println("引擎名字是");
            System.out.println(EngineName);
            System.out.println("引擎年龄是");
            System.out.println(EngineAge);
        }
        public Engine getInstance(){//若内部类被定义为私有的，此方法可以用于获取内部类
            System.out.println(Car.this.a);//内部类访问外部类成员:Car.this.a
            //内部类访问外部类成员:Car.this.a
            return new Engine();//只需要初始话外部类再到用此方法就获取到内布类
        }
    }

}

