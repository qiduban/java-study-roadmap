package com.java39_E;

/**
 * 测试 student_E 泛型类的测试类
 * 为 stu1 ~ stu5 生成测试数据
 */
public class TestStudent_E {

    public static void main(String[] args) {
        // 创建 5 个学生对象，泛型使用 String（姓名和年龄都用字符串存储）
        student_E<String> stu1 = new student_E<>();
        student_E<String> stu2 = new student_E<>();
        student_E<String> stu3 = new student_E<>();
        student_E<String> stu4 = new student_E<>();
        student_E<String> stu5 = new student_E<>();

        // stu1：张三，20岁
        stu1.setName("张三");
        stu1.setAge("20");

        // stu2：李四，21岁
        stu2.setName("李四");
        stu2.setAge("21");

        // stu3：王五，22岁
        stu3.setName("王五");
        stu3.setAge("22");

        // stu4：赵六，23岁
        stu4.setName("赵六");
        stu4.setAge("23");

        // stu5：孙七，24岁
        stu5.setName("孙七");
        stu5.setAge("24");

        // 输出测试数据
        System.out.println("=== 学生测试数据 ===");
        printStudent(stu1);
        printStudent(stu2);
        printStudent(stu3);
        printStudent(stu4);
        printStudent(stu5);
    }

    /**
     * 打印一个学生对象的信息
     */
    private static void printStudent(student_E<String> stu) {
        System.out.println("姓名：" + stu.getName() + "，年龄：" + stu.getAge());
    }
}
