package com.java39_Set;

import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.TreeSet;

public class HashSet_demo1 {
    public static void main(String[] args) {
        /*
            哈希值:
                对象的整数表现形式
                1.如果没有重写hashcode方法，不同对象计算出的哈希值是不同的
                2.如果已经重写hashcode方法，不同的对象只要属性值相同，计算出的哈希值就是一样的
                3.但是在小部分情况下，不同的属性值或者不同的地址值计算出来的哈希值也有可能一样。(哈希碰撞)
        */
//        创建对象
        student a = new student("111", 1);
        student b = new student("111", 1);
        student c = new student("222", 2);
        student d = new student("333", 3);
//        如果没有重写hashcode方法，不同对象计算出的哈希值是不同的
        System.out.println(a.hashCode());//295530567
        System.out.println(b.hashCode());//2003749087
//        如果已经重写hashcode方法，不同的对象只要属性值相同，计算出的哈希值就是一样的(需要在对象中重写HashCode（）方法)
        System.out.println(a.hashCode());
        System.out.println(b.hashCode());
//        3.但是在小部分情况下，不同的属性值或者不同的地址值计算出来的哈希值也有可能一样。(哈希碰撞)
        System.out.println("abc".hashCode());//96354
        System.out.println("acD".hashCode());//96354
        //利用HashSet的性质对数据去重
        HashSet<student> hs = new HashSet<>();
        System.out.println(hs.add(a));
        System.out.println(hs.add(b));
        System.out.println(hs.add(c));
        System.out.println(hs.add(d));
//  linkHashSet有序，其余与hashSet一致
        LinkedHashSet<student> lhs = new LinkedHashSet<>();
        System.out.println(lhs.add(a));
        System.out.println(lhs.add(b));
        System.out.println(lhs.add(c));
        System.out.println(lhs.add(d));
        for(student s : lhs){
            System.out.println(s.Name);
        }
//        TreeSet的特点
//            不重复、无索引、可排序
//            可排序:按照元素的默认规则(有小到大)排序。
//            TreeSet集合底层是基于红黑树的数据结构实现排序的，增删改查性能都较好。
        TreeSet<Integer> ts =new TreeSet<>();
        ts.add(1);
        ts.add(5);
        ts.add(4);
        ts.add(65);
        ts.add(21);
        System.out.println(ts);
        TreeSet<String> Ts =new TreeSet<>();
//        TreeSet集合默认的规则
//        对于数值类型:Integer，Double，默认按照从小到大的顺序进行排序。
//        对于字符、字符串类型:按照字符在ASCll码表中的数字升序进行排序。
//        treeset的底层代码是是红黑树所以不需要重写HashCode
        Ts.add("asfa");
        Ts.add("aae");
        Ts.add("aas");
        Ts.add("aad");
        Ts.add("aac");
        System.out.println(Ts);
        TreeSet<student> TS =new TreeSet<>();
        TS.add(a);
        TS.add(b);
        TS.add(c);
        TS.add(d);
        System.out.println(TS);
    }

}
