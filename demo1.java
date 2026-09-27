package com.java48;

import java.io.*;

public class demo1 {
    public static void main(String[] args) {
        try (
                //创建字符缓冲输入流
                Reader fr = new FileReader("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java48\\demo3");//会出现乱码
                //引入字符输入转换流（InputStreamRreader）解决编码不同造成的汉字乱码问题
                //创建原始字节输入流介入需要改变字符编码的源文件
                InputStream is = new FileInputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java48\\demo3");
                Reader r = new InputStreamReader(is,"GBK");//告诉r字节输入流以“GBK”的形式读取字节并转换成原始字节
                BufferedReader bfr = new BufferedReader(r);
                OutputStream os = new FileOutputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java48\\demo3");
                Writer w = new OutputStreamWriter(os,"GBK");
                Writer bw = new BufferedWriter(w);
                ){
            String line;
            bw.write("我爱你lyt");
            bw.write("\r\n");
            bw.write("hello world");
            bw.close();
            while((line = bfr.readLine()) != null){
                System.out.println(line);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
