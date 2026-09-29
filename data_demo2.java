package com.java48;

import java.io.*;
/*
* 数据类型一致：writeInt() 对应 readInt()。
* 数据顺序一致：先写 int 再写 double，读取时也必须先读 int 再读 double。
* */
public class data_demo2 {
    public static void main(String[] args) {
        try( //1.创建原始字节入流
             DataInputStream da =
                     new DataInputStream(new FileInputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java48\\Hello.txt"));
        ) {
            int a = da.readInt();
            System.out.println(a);
            double b = da.readDouble();
            System.out.println(b);
            String c = da.readUTF();
            System.out.println(c);
           } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }
}
