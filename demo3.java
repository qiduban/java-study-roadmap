package com.java48;

import java.io.FileNotFoundException;
import java.io.PrintStream;

public class demo3 {
    public static void main(String[] args) {
        System.out.println("114514");
        System.out.println("lyt");
        try (
                PrintStream ps = new PrintStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java48\\Hello.txt");
                ){
            System.setOut(ps);//替换系统默认的打印流
            System.out.println("114514");
            System.out.println("lyt");
        } catch (FileNotFoundException e) {
            throw new RuntimeException(e);
        }

    }
}
