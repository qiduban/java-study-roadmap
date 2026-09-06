package com.java42;

import java.util.*;
import java.util.stream.Collectors;

public class collect_demo1 {
    public static void main(String[] args) {
        ArrayList<String> list = new ArrayList<>();
        //收集List集合当中
        //需求:
        //我要把所有的男/女性收集起来
        Collections.addAll(list,"张无-男-15","周芷若-女-14","赵敏-女-13","张强-男-20","张三丰-男-100","张翠山-男-40","张良-男-35","王二麻子-男-37","谢广坤-男-41");
        List<String> newList = list.stream().filter(s->"男".equals(s.split("-")[1])).collect(Collectors.toList());
        List<String> NewList = list.stream().filter(s->("女".equals(s.split("-")[1]))).collect(Collectors.toList());
        System.out.println(newList);
        System.out.println(NewList);
        //收集Map集合当中
        //谁作为键，谁作为值.
        //我要把所有的男性收集起来
        //键:姓名。值:年龄
        Map<String,Integer> newMAp = list.stream().filter(s->"男".equals(s.split("-")[1])).collect(Collectors.toMap(s1->s1.split("-")[0],s1->Integer.parseInt(s1.split("-")[2])));
        System.out.println(newMAp);
        /*toMap(
    第一个参数：决定 Key 是什么,
    第二个参数：决定 Value 是什么
    )
    Collectors.toMap(
    s -> xxx,    // Key怎么来
    s -> xxx     // Value怎么来
                    toMap()
                  │
        ┌─────────┴─────────┐
        ↓                   ↓
   第一个函数            第二个函数
   Key怎么来             Value怎么来
        ↓                   ↓
s.split("-")[0]     Integer.parseInt(
                           s.split("-")[2]
                       )
        ↓                   ↓
      张三                  15
      五、为什么第一个是 Key，第二个是 Value？
      因为 toMap() 的方法定义就是这个逻辑：
    Collectors.toMap(
    Function<? super T, ? extends K> keyMapper,
    Function<? super T, ? extends U> valueMapper
    用你的代码理解就是
    .collect(Collectors.toMap(
    new Function<String, String>() {
        @Override
        public String apply(String s) {
            return s.split("-")[0];
        }
    },
    new Function<String, Integer>() {
        @Override
        public Integer apply(String s) {
            return Integer.parseInt(s.split("-")[2]);
        }
    }
));
第一个：
new Function<String, String>()
表示：
输入(stream流中的每个数据) String
输出 String
也就是：
String → String
你的数据(stream流中的每个数据)：
张三-男-15
经过：
s -> s.split("-")[0]
变成：
张三
所以：
String → String
这个函数负责：
Key

第二个：
new Function<String, Integer>()
表示：
输入 String
输出 Integer
也就是：
String → Integer
你的数据(stream流中的每个数据)：
张三-男-15
经过：
s -> Integer.parseInt(s.split("-")[2])
变成：
15
所以：
String → Integer
这个函数负责：
Value
)
)*/

    }
}
