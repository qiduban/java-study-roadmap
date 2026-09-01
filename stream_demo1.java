package com.java42;

import java.util.ArrayList;

public class stream_demo1 {
    public static void main(String[] args) {
        ArrayList<String> list1 = new ArrayList<>();
        list1.add("张无忌");
        list1.add("周芷若");
        list1.add("赵敏");
        list1.add("张强");
        list1.add("张三丰");
        //1.把所有以“张”开头的元素存储到新集合中for (String name : list1) {if(name.startsWith("K")){list2.add(name);
        ArrayList<String> list2 = new ArrayList<>();
        for (String name : list1) {
            if(name.length() == 3){
                list2.add(name);
            }
        }
        //2.把“张”开头的，长度为3的元素再存储到新集合中
            ArrayList<String> list3 = new ArrayList<>();
        //3.遍历打印最终结果
            for (String name : list3) {
                System.out.println(name);
            }
            list1.stream().filter(o1 -> o1.startsWith("张")).filter(o1->o1.length()==3).forEach(o1-> System.out.println(o1));
    }
}
