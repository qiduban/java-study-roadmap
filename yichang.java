package com.java44;

import java.text.SimpleDateFormat;
import java.util.Date;

public class yichang {
/*
* Exception:叫做异常，代表程序可能出现的问题。
* 我们通常会用Exception以及他的子类来封装程序出现的问题。
* 运行时异常:
*          RuntimeException及其子类，编译阶段不会出现异常提醒。
*          运行时出现的异常(如:数组索引越界异常)
*编译时异常:
*         编译阶段就会出现异常提醒的。(如:日期解析异常)
*异常作用一:异常是用来查询bug的关键参考信息
*异常作用二:异常可以作为方法内部的一种特殊返回值，以便通知调用者底层的执行情况
*出现异常后虚拟机就不会处理一场以下的代码了
*
* */
public static void main(String[] args) {
    //编译时异常(在编译阶段必须手动处理否则代码报错)
    //String time = "2030年1月1H";
    //SimpleDateFormat sdf = new SimpleDateFormat("yyyyEMM月ddIl");
    //Date date = sdf.parse(time);
    //System.out.println(date);
//运行时异常（在编译时不需要处理，是运行时出现的错误）
    //int[] arr = {1,2,3,4,5};
    //System.out.println(arr[10]);
    student stu =new student();
    stu.setAge(101010101);
}
}
