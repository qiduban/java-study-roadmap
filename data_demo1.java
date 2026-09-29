package com.java48;

import java.io.DataOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;

public class data_demo1 {
    public static void main(String[] args) {
        try(
                //1.创建一个低级的数据输出流包装字节输出流
                DataOutputStream ds =
                        new DataOutputStream(new FileOutputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java48\\Hello.txt"));
                ) {
            ds.writeInt(1);
            ds.writeDouble(1.23);
            ds.writeUTF("114514");//?�z�G� 114514 乱码是正常现象（文本查看器无法查看二进制数据）
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
