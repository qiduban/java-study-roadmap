package com.java36_array;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.function.Consumer;

public class test {
    public static void main(String[] args) {
        Collection<String> coll = new ArrayList<>();
        coll.add("aaa");
        coll.add("bbb");
        coll.add("ccc");
        coll.add("114514");
        System.out.println(coll);
        System.out.println(coll.remove("aaa"));
        System.out.println(coll);
        //coll.clear();
        System.out.println(coll);
//        Iterator<String> it = coll.iterator();//迭代器默认指向0索引
//        while(it.hasNext()){
//            boolean A = it.hasNext();
//            System.out.println(A);
//            String str = it.next();
//            if("114514".equals(str)){
//                it.remove();
//                return;
//            }
//            System.out.println(str);
//        }//迭代器遍历
//        for(String a : coll){
//            System.out.println(a);
//        }//增强for遍历
//          lambda表达式遍历
        coll.forEach(new Consumer<String>() {
            @Override
            //s就是复制列表中的变量的变量
            public void accept(String s) {
                System.out.println(s);
            }
        });
        coll.forEach(s->{
            System.out.println(s);
        });

    }
}
