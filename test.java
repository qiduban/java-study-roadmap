package com.java39_Set;

import java.util.HashSet;
import java.util.Set;

public class test {
    public static void main(String[] args) {
        //创建一个Set集合
        Set<String> S =new HashSet<>();
        S.add("114514");//true
        S.add("114514");//false Set集合元素具有唯一性添加同一元素会返回Boolean值False
        S.add("wms");
        S.add("lyt");
        System.out.println(S);//输出结果[lyt, 114514, wms]set集合是无序的，取出和输出顺序不对应
        S.forEach(name -> System.out.println(name + "!"));//利用lambda遍历集合


    }
}
