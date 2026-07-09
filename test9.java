package com.lyt.study;

import java.util.Scanner;

public class test9 {
    public static void main(String[] args) {
        Scanner sf = new Scanner(System.in);
        double a = sf.nextDouble();
        double i = 0;
        double b = 0;
        b = 2 * a;
        while(a < b){
            a += a*0.017;
            i++;
        }
        System.out.println(i);
    }
}
