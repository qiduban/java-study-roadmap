package com.lyt.study;

//import java.awt.image.DataBufferDouble;
import java.util.Scanner;

public class wms {
    public static void main(String[] args) {
       // System.out.println("hello world");
        System.out.println("day2");
        Scanner pt = new Scanner(System.in);
        double height;
        double weight;
        System.out.println("请输入身高");
        height = pt.nextDouble();
        System.out.println("请输入体重");
        weight = pt.nextDouble();
        double BMI = (weight / (height * height));
        System.out.println("现在开始输出BMI");
        System.out.println(BMI);
    }
}
