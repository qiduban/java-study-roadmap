package com.java48;

import java.io.*;
import java.nio.charset.Charset;

public class print_demo1 {
    public static void main(String[] args) {
        /**
         * PrintStream 构造方法：
         *
         * 1. public PrintStream(OutputStream / File / String)
         *    // 打印流直接通向字节输出流、文件或文件路径
         *
         * 2. public PrintStream(String fileName, Charset charset)
         *    // 可以指定写出时的字符编码
         *
         * 3. public PrintStream(OutputStream out, boolean autoFlush)
         *    // 可以指定是否实现自动刷新
         *
         * 4. public PrintStream(OutputStream out, boolean autoFlush, String encoding)
         *    // 可以指定是否自动刷新，并且可以指定字符的编码
         *
         *
         * PrintStream 常用方法：
         *
         * 1. public void println(xxx)
         *    // 打印任意类型的数据出去
         *
         * 2. public void write(int / byte[] / byte[] 的一部分)
         *    // 可以支持写字节数据出去
         */
        try (
                //可用charset.forNAme自定义编码器
                PrintStream ps =new PrintStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java48\\Hello.txt");
        ){
            ps.println("woailyt");//打印流会自动刷新
            ps.println("lyt ai wms");//可以自动刷新
            ps.write(97);//以字节的方法写入‘a’;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
