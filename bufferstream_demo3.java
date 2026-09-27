package com.java47;

import javax.xml.transform.Source;
import java.io.*;

public class bufferstream_demo3 {
    public static void main(String[] args) {
        try (
                //创建字符输入流和字符输出流
                Reader re = new FileReader("C:\\Users\\34005\\Desktop\\io_test_1g.txt");
                //升级成缓冲字符输入流
                BufferedReader bre = new BufferedReader(re,1024 * 8);//可自定义缓冲池的大小+
                //创建字符输出流用于复制文件
                Writer wr = new FileWriter("C:\\Users\\34005\\Desktop\\111.txt");
                //升级为缓冲字节输出流
                BufferedWriter bwr = new BufferedWriter(wr);
                ){
            long startTime = System.currentTimeMillis();
            char []buffer = new char[1024];
            int len = 0;
            while((len = bre.read(buffer)) != -1){
                bwr.write(buffer);
            }
            long endTime = System.currentTimeMillis();
            System.out.println((endTime-startTime)/1000.0);
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
