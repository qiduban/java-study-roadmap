package com.java48;

import java.io.*;
import java.util.ArrayList;
import java.util.Collections;

public class object_demo1 {
    public static void main(String[] args) {
        //创建一个自定义对象
        student lyt = new student("lyt",21,5709);
        student wms = new student("wms",21,4439);
        //创建序列输出流连你姐文件
        try (
                ObjectOutputStream op = new ObjectOutputStream(new FileOutputStream("Hello.txt"));
                ObjectInputStream oi = new ObjectInputStream(new FileInputStream("D:\\Dev\\Projects\\study_day1\\Hello.txt"));

        ){
            /*序列化单个数据
            op.writeObject(lyt);
            System.out.println("序列化成功");
            student u = (student)oi.readObject();
            System.out.println(u);
            op.close();
          */
            //序列化多个数据
            //用arraylist数组承接student类型数据
            ArrayList<student> stu = new ArrayList();
            Collections.addAll(stu,lyt,wms);
            op.writeObject(stu);
            //关闭输入流刷新文件状态
            op.close();
            ArrayList<student> read = new ArrayList<>();
            read = (ArrayList<student>)oi.readObject();
            read.stream().forEach(System.out::println);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
