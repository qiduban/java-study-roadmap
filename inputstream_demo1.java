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
        InputStream is =new FileInputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\1.txt");
        int cout = 0;
/*遍历读取文件（效率很差）每次只会读取一个字节
        int a;
        while ((a = is.read()) != -1) {
            System.out.print((char) a);//读取汉字会乱码
        }
        //关闭流，释放系统资源
        is.close();*/
        /*byte []buffer = new byte[3];
        cout = is.read(buffer);//用数组一次性读完文件中的所有字节类型数据,并返回读取的字节数
        String s = new String(buffer);
        System.out.println(s);//abc
        System.out.println(cout);
        cout = is.read(buffer);//用数组一次性读完文件中的所有字节类型数据,并返回读取的字节数
        s = new String(buffer);//一定不要漏写函数名
        System.out.println(s);//c77
        System.out.println(cout);
        //通过用数组读取字节是默认为覆盖原则
        String s2 = new String(buffer,0,cout);//通过string的重载调用同名方法来实现指定读取长度和开都的位置
        System.out.println(s2);*/
        //用循环优化读取（不能解决汉字输出乱码问题）
        byte []b =new byte[3];
        while((cout = is.read(b)) != -1){
            String t = new String(b,0, cout);
            System.out.print(t);
        }
        is.close();
    }
}
