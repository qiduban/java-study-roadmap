package com.java47;

import javax.sound.midi.Soundbank;
import java.io.FileReader;
import java.io.Reader;
import java.util.Arrays;

public class filereader_demo1   {
    public static void main(String[] args) {
        try (
                //创建字符流输入管道与原文件接通
                Reader fr = new FileReader("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\output_demo1.txt");
                ){
            int c = 0;//.read返回的是整形数据
            //2.读取单个字符
            /*while((c = fr.read()) != -1){
                System.out.print((char)c);
            }*/
            //3.读取多个字符
            char []ch = new char[20];
            int len = 0;
            while((len = fr.read(ch))!= -1){
                System.out.println(Arrays.toString(ch));
                // System.out.print(new String(ch , 0 ,len));
            }
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
