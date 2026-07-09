package com.lyt.study;

import java.util.Scanner;

public class test3 {
    public static void main(String[] args) {
        int a , b;
        Scanner sf = new Scanner(System.in);
        System.out.println("输入a，b");
        a = sf.nextInt();
        b = sf.nextInt();
        System.out.println(a > b ? a : b);
    }
}
