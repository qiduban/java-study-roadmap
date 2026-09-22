package com.java47;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
//字符输出流只有在输出流刷新以后或者关闭以后才能在文件中看见输出的内容
/*
* public void flush() throws IOException        刷新流，就是将内存中缓存的数据立即写到文件中去生效!
* public void close() throws IOException          关闭流的操作，包含了刷新!
* */
public class filewriter_demo1 {
    public static void main(String[] args) {
        /*public FileWriter(File file)                              创建字节输出流管道与源文件对象接通
          public FileWriter(String filepath)                        创建字节输出流管道与源文件路径接通
          public FileWriter(File file, boolean append)              创建字节输出流管道与源文件对象接通,可追加数据
          public FileWriter(String filepath, boolean append)        创建字节输出流管道与源文件路径接通，可追加数据
        */
        //1.创建所需字符输入流和字符输出流
        try (
                FileWriter fw = new FileWriter("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\Hello.txt",true);
                FileReader fr = new FileReader("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\output_demo1.txt");
                ){
                    //2.写一个字符出去
                    fw.write("i");
                    fw.write(" ");
                    fw.write("l");
                    fw.write(" ");
                    fw.write("l");
                    fw.write("y");
                    fw.write("t");
                    //3.写一个字符串出去
                    fw.write("\r\n我爱卢玥曈");
                    //4.写字符串的一部分出去
                    fw.write("\r\nhello java!!!",0,6);
                    //5.写一个数组
                    char [] buffer = {'a','b','c'};
                    fw.write("\r\n");
                    fw.write(buffer);
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
