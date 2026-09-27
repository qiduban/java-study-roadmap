package com.java48;

import java.io.*;

//目标是写一个GBK编码的文件并读出
public class demo2 {
    public static void main(String[] args) {
        try (
                //创建输出流
                OutputStream os = new FileOutputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java48\\demo4",true);//可追加数据
                //创建转化流
                Writer w =new OutputStreamWriter(os,"GBK");
                //创建缓冲流
                BufferedWriter bw =new BufferedWriter(w);
                //创建字节输入流
                FileInputStream is = new FileInputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java48\\demo4");
                //创建转换流
                Reader r = new InputStreamReader(is,"GBK");
                //创建缓存流
                BufferedReader br = new BufferedReader(r);
                ){
                    //写入数据
                    bw.write("114514");
                    bw.write("\r\n2233");
                    bw.write("\r\n我爱卢玥曈");
                    //关闭流使文件创建
                    bw.close();
                    //开始读取数据
                    String line;
                    while ((line = br.readLine()) != null){
                        System.out.println(line);
                    }
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
