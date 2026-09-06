package com.java42;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class stream_test {
    public static void main(String[] args) {
        List<Integer> newlist = new ArrayList<>();
        Collections.addAll(newlist,1,2,3,4,5,6,7,8,9,0,12,21,34,3,45,567,67,8,34,4,56);
        newlist = newlist.stream().filter(s -> s % 2 != 0).collect(Collectors.toList());
        System.out.println(newlist);
        ArrayList<String> list = new ArrayList<>();
        // 2. 添加姓名,年龄 的字符串
        list.add("zhangsan,23");
        list.add("lisi,24");
        list.add("wangwu,25");
        Map<String,String> map =  list.stream().filter(s->Integer.parseInt(s.split(",")[1]) >= 24).collect(Collectors.toMap(s->s.split(",")[0], s->s.split(",")[1]));
        System.out.println(map);
    }
}
