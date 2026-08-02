package com.java33;

public class test {
    public static void main(String[] args) {
        Student a = new Student("卢玥曈" , 21 , "女" , "红梅西村");
        System.out.println(a.getAge() + "岁" + "名字是" + a.getName() + "的" + "住在" + a.getAddress() + "的" + a.getGander() + "生");
        a.work();
    }
}
