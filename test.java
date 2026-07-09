package com.lyt.study;

import java.sql.SQLOutput;
import java.util.Scanner;

public class test {
    public static void main(String[] args) {
        Scanner sf = new Scanner(System.in);
        System.out.println("现在开始输入身高");
        double height = sf.nextDouble();
        System.out.println("现在开始输入体重");
        double weight = sf.nextDouble();
        double BMI = weight/(height * height);
        System.out.println(BMI);
    }
}
