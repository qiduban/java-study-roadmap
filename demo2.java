package com.java43;

import com.sun.source.tree.NewArrayTree;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

public class demo2 {
    public static void main(String[] args) {
        //1.静态方法的引用
        //Integer::paseInt
        List<String> list = new ArrayList<>();
        String []arr = {"1","2","3","4"};
        Collections.addAll(list,arr);
        /*
        一、静态方法引用
            语法:
                类名::静态方法名
        */
        //list.stream().map(s->Integer.parseInt(s)).forEach(System.out::println);
        list.stream().map(Integer::parseInt).forEach(System.out::println);
        //map() 的核心作用就一句话:把 Stream 中的每一个元素，转换成另外一个元素。
        /*
        *方法引用(引用成员方法)格式
        *       本类:this::方法名
        *       其他类:其他类对象::方法名
        *       父类:super::方法名
        *需求:
        *集合中有一些名字，按照要求过滤数据数据:"张无忌”，"周芷若”，"赵敏"，”张强”，”张三丰”
        * 要求:只要以张开头，而且名字是3个字的
        */
       ArrayList<String> Name =new ArrayList<>();
       StringOperation op =new StringOperation();
       Collections.addAll(Name,"张无忌","周芷若","赵敏","张强","张三丰");
       Name.stream().filter(s -> s.startsWith("张")).filter(s -> s.length() == 3).forEach(System.out::println);
       Name.stream().filter(op::stringJudege).forEach(System.out::println);
       Name.stream().filter(new demo2()::stringJudege1).forEach(System.out::println);
    }
    public boolean stringJudege1(String s){
        return s.length() == 3 && s.startsWith("张");
    }
}
