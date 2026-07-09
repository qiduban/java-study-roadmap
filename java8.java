package com.lyt.study;

import java.util.Scanner;

public class java8 {
    public static void main(String[] args) {
        Scanner sf = new Scanner(System.in);
        int n = sf.nextInt();
        for(int i = 0 ; i < n ; i++){
            if(i % 2 == 0){
                System.out.println(i * -1);
            }
            else{
                System.out.println(i);
            }
        }
    }
}
