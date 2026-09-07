package com.java43;

import com.sun.source.tree.NewArrayTree;

import java.util.Arrays;
import java.util.Comparator;
import java.util.function.Consumer;

public class demmo1 {
    public static void main(String[] args) {
        Integer []arr = {3,3,2,5,2,7,9};
        Arrays.sort(arr, new Comparator<Integer>() {
            @Override
            public int compare(Integer o1, Integer o2) {
                return o1 - o2;
            }

            @Override
            public boolean equals(Object obj) {
                return false;
            }
        });
        //lambda表达式
//因为第二个参数的类型Comparator是一个函数式接口
        //return o2 - o1;
        /*Arrays.sort(arr, (Integer o1, Integer o2)->{
            ;*/
//1ambda表达式简化格式
//Arrays.sort(arr, (o1, o2)->o2 - o1 );
//方法引用
//1.引用处需要是函数式接口
//2.被引用的方法需要已经存在//3.被引用方法的形参和返回值需要跟抽象方法的形参和返回值保持一致
//4.被引用方法的功能需要满足当前的要求
//表示引用FunctionDemo1类里面的subtraction方法//把这个方法当做抽象方法的方法体
        Arrays.sort(arr , demmo1::subtraction);
            System.out.println(Arrays.toString(arr));
        Consumer<String> consumer = System.out::println;
        consumer.accept("114514");
        //1.
    }
    public static  int subtraction(Integer o1 , Integer o2){
        return o1 - o2;
    }
}
