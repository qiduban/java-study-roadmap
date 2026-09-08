package com.java43;

import com.sun.source.tree.NewArrayTree;

import java.util.*;
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
       Collections.addAll(Name,"张无忌","卢玥曈,22","赵敏","张强","张三丰");
       Name.stream().filter(s -> s.startsWith("张")).filter(s -> s.length() == 3).forEach(System.out::println);
       Name.stream().filter(op::stringJudege).forEach(System.out::println);
       Name.stream().filter(new demo2()::stringJudege1).forEach(System.out::println);
       Map m = Name.stream().filter(s -> s.length() > 3).map(String::strip).collect(Collectors.toMap(s1 -> s1.split(",")[0], s1 -> Integer.parseInt(s1.split(",")[1])));
       Name.stream().filter(s -> s.length() > 3).map(student::new).forEach(student::study);
        System.out.println(m);
        student a = new student("1",1);
        /*方法引用的规则:
                        1.需要有函数式接口
                        2.被引用的方法必须已经存在
                        3.被引用方法的形参，需要跟抽象方法的第二个形参到最后一个形参保持一致，返回值需要保持一致。
                        4.被引用方法的功能需要满足当前的需求
                        抽象方法形参的详解:
                        第一个参数:表示被引用方法的调用者，决定了可以引用哪些类中的方法
                        在Stream流当中，第一个参数一般都表示流里面的每一个数据。
                        假设流里面的数据是字符串，那么使用这种方式进行方法引用，只能引用String这个类中的方法
                        第二个参数到最后一个参数:跟被引用方法的形参保持一致，如果没有第二个参数，说明被引用的方法需要是无参的成员方法
                        局限性:
                        不能引用所有类中的成员方法。
                        是跟抽象方法的第一个参数有关，这个参数是什么类型的，那么就只能引用这个类中的方法。*/
        ArrayList<Integer> list2 = new ArrayList<>();
        Collections.addAll(list2,1,2,3,4,5,6,7,8,9);
        Integer []array = list2.stream().toArray(Integer[]::new);
        System.out.println(Arrays.toString(array));
    }

    public boolean stringJudege1(String s){
        return s.length() == 3 && s.startsWith("张");
    }
}
