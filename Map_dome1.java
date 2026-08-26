package com.java40_Map;

import java.util.HashMap;
import java.util.Map;

public class Map_dome1 {
    public static void main(String[] args) {
//        V put(K key,V value)                  添加元素
//        V remove(Object key)                  根据键删除键值对元素
//        void clear()                          移除所有的键值对元素
//        boolean containsKey(Object key)       判断集合是否包含指定的键
//        boolean containsValue(Object value)   判断集合是否包含指定的值
//        boolean isEmpty()                     判断集合是否为空
//        int size()                            集合的长度，也就是集合中键值对的个数
//        Set KeySet()                          获取集合内所有键并返回一个Set集合
        //1.创建Map集合对象
        Map<String,String> M = new HashMap<>();
        //2.添加对象
        //put方法的细节:
        //添加/覆盖
        //在添加数据的时候，如果键不存在，那么直接把键值对对象添加到map集合当中
        // 在添加数据的时候，如果键是存在的，那么会把原有的键值对对象覆盖，会把被覆盖的值进行返回。
        M.put("1","一");
        M.put("2","二");
        M.put("3","三");
        String value = M.put("3","san");
        System.out.println(M);
        System.out.println(value);
        String result = M.remove("3");
        System.out.println(result);
        System.out.println(M);
        System.out.println(M.size());
        System.out.println(M.containsKey("1"));
        System.out.println(M.containsValue("一"));
        System.out.println(M.get("san"));
        System.out.println(M.isEmpty());
        M.clear();
        System.out.println(M.isEmpty());
        System.out.println(M.size());
        System.out.println(M.containsKey("1"));
        System.out.println(M.containsValue("一"));
        M.put("1","一");
        M.put("2","二");
        M.put("3","三");
        M.put("4","四");
        M.put("5","五");
        M.put("6","六");
//        for(String tmp : M.keySet()){
//            String Tmp = M.get(tmp);
//            System.out.println("key = " + tmp + " = " + Tmp);
//        }

        for(String tmp : M.keySet()){
            in
              String Tmp = M.get(tmp);
              System.out.println("key = " + tmp + " = " + Tmp);
          }
    }
}
