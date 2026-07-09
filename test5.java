package com.lyt.study;

import java.util.Scanner;

public class test5 {
    public static void main(String[] args) {
        Scanner sf = new Scanner(System.in);
        System.out.println("现在开始输入用电量");
        double pc = sf.nextDouble();
        double price = 0;
        if(price > 0 && price <= 100) price = pc * 0.5;
        else if(price > 100 && price <= 200) price = pc * 0.8;
        else price = pc * 1.2;
        System.out.println(price);

    }
}
