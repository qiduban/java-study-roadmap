package com.java47;

import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

public class test {
    public static void main(String[] args) throws UnsupportedEncodingException {
        //1.编码
        String data = "i l 卢玥曈 ！";
        //2.按照平台默认编码器编码（UTF-8）
        byte []bytes = data.getBytes();
        System.out.println(Arrays.toString(bytes));
        //3.自定义编码器
        byte []bytes1 = data.getBytes("GBK");
        System.out.println(Arrays.toString(bytes1));
        //4解码
        String a = new String(bytes);//平台默认编码器编码
        String b = new String(bytes1);
        String c = new String(bytes1,"GBK");
        System.out.println(a);
        System.out.println(b);//解码器不匹配会导致出现乱码"��"
        System.out.println(c);
    }
}
