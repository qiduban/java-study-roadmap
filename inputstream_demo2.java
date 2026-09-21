package com.java47;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.nio.channels.ClosedByInterruptException;

public class inputstream_demo2 {
    public static void main(String[] args) throws Exception{
        //1.创建一个输入流并接入文件
        InputStream is = new FileInputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\demo2.txt");
        InputStream Is = new FileInputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\demo2.txt");
        //创建一个刚好和数组一样大的byte数组来避免读取时出现中文字符乱码问题
        File f = new File("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\demo2.txt");
        long size = f.length();//int 类型可能无法满足对文件大小记录的要求所以java系统中默认采用long类型
        //2.1创建byte数组读取数据
        byte []buffur = new byte[(int)size];
        //2.2
        byte []Buffer = is.readAllBytes();
        //3.读取文件数据
        Is.read(buffur,0,(int)size);
        String s = new String(buffur);
        String S =new String(Buffer);
        System.out.println(s);
        System.out.println(S);
        //4.关闭流
        is.close();
    }
}
