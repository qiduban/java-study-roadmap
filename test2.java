package com.lyt.study;

import java.util.Scanner;

public class test2 {
    public static void main(String[] args){
        Scanner sf = new Scanner(System.in);
        System.out.println("现在开始输入所需录入的数据");
        int time = sf.nextInt();
        int hour = time / 3600;
        int mim = time % 3600 / 60;
        int sec = time % 3600 % 60;
        System.out.println(hour + "小时" + mim + "分钟" + sec + "秒" );
        System.out.println(mim);
        System.out.println(sec);
    }
}
