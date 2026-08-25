package com.java39_Set;

import java.util.TreeSet;

public class TreeSet_demo {
    public static void main(String[] args) {
        // 使用带参构造创建5个 Stu 类型变量
        Stu stu1 = new Stu("张三", 18, 90, 85, 88);
        Stu stu2 = new Stu("李四", 19, 78, 92, 80);
        Stu stu3 = new Stu("王五", 18, 85, 88, 91);
        Stu stu4 = new Stu("赵六", 20, 95, 97, 93);
        Stu stu5 = new Stu("孙七", 19, 82, 79, 86);
        Stu stu6 = new Stu("张四", 18, 90, 85, 88);
        // 创建TreeSet集合并将变量添加进集合
        TreeSet<Stu> set = new TreeSet<>((o1,o2)->{
            int i = o1.all - o2.all;
                if(i == 0){
                    i = o1.Grade_Chinese - o2.Grade_Chinese;
                    if (i == 0){
                        i = o1.getGrade_Math() - o2.Grade_Math;
                        if(i == 0){
                            i = o1.Age - o2.Age;
                            if(i == 0){
                                i = o1.Name.compareTo(o2.Name);
                            }
                        }
                    }
                }
            return i;
        });
        set.add(stu1);
        set.add(stu2);
        set.add(stu3);
        set.add(stu4);
        set.add(stu5);
        System.out.println(set.add(stu6));
        System.out.println(set);
    }
}
