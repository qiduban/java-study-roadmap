package com.lyt.study;

import java.util.Scanner;

public class test4 {
    public static void main(String[] args) {
        Scanner sf = new Scanner(System.in);
        System.out.println("现在开始输入金额");
        double price = sf.nextDouble();
        double a = price * 0.9;
        double b = price;
        if(price >= 30) b = price - 10;
        double mim;
        mim = a;
        if(b < a) mim =b;
        System.out.println(b);
        System.out.println(a < b ? a : b);
    }
}
