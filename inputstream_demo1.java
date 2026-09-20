package com.java47;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;

public class inputstream_demo1 {
    public static void main(String[] args) throws Exception {//java会默认报错防止你的文件地址是个无效地址
        //完整创建方法
        //InputStream is = new FileInputStream(new File("C:\\Users\\34005\\Desktop\\java-io-test"));完整确立方法
        //1.简略创建方法(java底层会将传进来的对象自动改为file类型)
        InputStream is =new FileInputStream("C:\\Users\\34005\\Desktop\\java-io-test\\level2\\level3\\targets.txt");

/*遍历读取文件（效率很差）每次只会读取一个字节
        int a;
        while ((a = is.read()) != -1) {
            System.out.print((char) a);//读取汉字会乱码
        }
        //关闭流，释放系统资源
        is.close();*/
        byte []buffer = new byte[1024];
        int cout = is.read(buffer);//用数组一次性读完文件中的所有字节类型数据,并返回读取的字节数
        String s = new String(buffer);
        System.out.println(s);
        System.out.println(cout);
    }
}
