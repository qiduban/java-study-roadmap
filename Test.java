package com.java34;

public class Test extends Training_plan_Adapter {

    // ========== 重写部分训练计划方法用于测试 ==========
    @Override
    public void Plan1() {
        System.out.println("执行训练计划一：基础体能训练");
    }

    @Override
    public void Plan2() {
        System.out.println("执行训练计划二：技术动作训练");
    }

    @Override
    public void Plan3() {
        System.out.println("执行训练计划三：战术配合训练");
    }

    // ========== main 方法：全面调试所有类与接口 ==========
    public static void main(String[] args) {
        System.out.println("========== 1. 测试 Basketball 类（继承 Player）==========");
        Basketball basketballPlayer = new Basketball("张三", 18);
        System.out.println("姓名: " + basketballPlayer.getName() + ", 年龄: " + basketballPlayer.getAge());
        System.out.print("运动: ");
        basketballPlayer.Piaying();

        // 测试 setter
        basketballPlayer.setName("张三丰");
        basketballPlayer.setAge(19);
        System.out.println("修改后 -> 姓名: " + basketballPlayer.getName() + ", 年龄: " + basketballPlayer.getAge());

        // 测试空参构造
        Basketball basketballPlayer2 = new Basketball();
        basketballPlayer2.setName("李四");
        basketballPlayer2.setAge(20);
        System.out.println("空参构造 -> 姓名: " + basketballPlayer2.getName() + ", 年龄: " + basketballPlayer2.getAge());

        System.out.println("\n========== 2. 测试 Pingpang 类（继承 Player + 实现 EngLish）==========");
        Pingpang pingpangPlayer = new Pingpang("王五", 16);
        System.out.println("姓名: " + pingpangPlayer.getName() + ", 年龄: " + pingpangPlayer.getAge());
        System.out.print("运动: ");
        pingpangPlayer.Piaying();
        System.out.print("语言能力: ");
        pingpangPlayer.English();

        // 测试空参构造
        Pingpang pingpangPlayer2 = new Pingpang();
        pingpangPlayer2.setName("赵六");
        pingpangPlayer2.setAge(17);
        System.out.println("空参构造 -> 姓名: " + pingpangPlayer2.getName() + ", 年龄: " + pingpangPlayer2.getAge());

        System.out.println("\n========== 3. 测试 Breaketball_Coach 类（继承 Coach）==========");
        Breaketball_Coach basketballCoach = new Breaketball_Coach("刘教练", 35);
        System.out.println("姓名: " + basketballCoach.getName() + ", 年龄: " + basketballCoach.getAge());
        System.out.print("教学: ");
        basketballCoach.Teaching();

        // 测试空参构造
        Breaketball_Coach basketballCoach2 = new Breaketball_Coach();
        basketballCoach2.setName("陈教练");
        basketballCoach2.setAge(40);
        System.out.println("空参构造 -> 姓名: " + basketballCoach2.getName() + ", 年龄: " + basketballCoach2.getAge());

        System.out.println("\n========== 4. 测试 Pingpang_Coach 类（继承 Coach + 实现 EngLish）==========");
        Pingpang_Coach pingpangCoach = new Pingpang_Coach("孙教练", 30);
        System.out.println("姓名: " + pingpangCoach.getName() + ", 年龄: " + pingpangCoach.getAge());
        System.out.print("教学: ");
        pingpangCoach.Teaching();
        System.out.print("语言能力: ");
        pingpangCoach.English();

        // 测试空参构造
        Pingpang_Coach pingpangCoach2 = new Pingpang_Coach();
        pingpangCoach2.setName("周教练");
        pingpangCoach2.setAge(32);
        System.out.println("空参构造 -> 姓名: " + pingpangCoach2.getName() + ", 年龄: " + pingpangCoach2.getAge());

        System.out.println("\n========== 5. 测试多态：父类引用指向子类对象 ==========");
        // Player 父类引用
        Player p1 = new Basketball("多态篮球手", 14);
        Player p2 = new Pingpang("多态乒乓手", 15);
        System.out.print("p1 (Player -> Basketball): ");
        p1.Piaying();
        System.out.print("p2 (Player -> Pingpang): ");
        p2.Piaying();

        // Coach 父类引用
        Coach c1 = new Breaketball_Coach("多态篮球教练", 38);
        Coach c2 = new Pingpang_Coach("多态乒乓教练", 42);
        System.out.print("c1 (Coach -> Breaketball_Coach): ");
        c1.Teaching();
        System.out.print("c2 (Coach -> Pingpang_Coach): ");
        c2.Teaching();

        System.out.println("\n========== 6. 测试 EngLish 接口多态 ==========");
        EngLish englishPlayer = new Pingpang("英语乒乓手", 20);
        EngLish englishCoach = new Pingpang_Coach("英语乒乓教练", 36);
        System.out.print("englishPlayer (EngLish -> Pingpang): ");
        englishPlayer.English();
        System.out.print("englishCoach (EngLish -> Pingpang_Coach): ");
        englishCoach.English();

        System.out.println("\n========== 7. 测试 Training_plan 接口与适配器模式 ==========");
        Test test = new Test();
        System.out.println("--- 执行已重写的计划 ---");
        test.Plan1();
        test.Plan2();
        test.Plan3();
        System.out.println("--- 执行适配器默认空实现计划 ---");
        test.Plan4();  // 空实现，无输出
        test.Plan5();  // 空实现，无输出
        System.out.println("（Plan4~Plan9 均为空实现，无输出）");

        // 多态：Training_plan 引用
        Training_plan tp = new Test();
        System.out.print("Training_plan 引用调用 Plan1: ");
        tp.Plan1();
        System.out.print("Training_plan 引用调用 Plan2: ");
        tp.Plan2();

        System.out.println("\n========== 8. 测试 instanceof 类型判断 ==========");
        System.out.println("basketballPlayer instanceof Player: " + (basketballPlayer instanceof Player));
        System.out.println("pingpangPlayer instanceof Player: " + (pingpangPlayer instanceof Player));
        System.out.println("pingpangPlayer instanceof EngLish: " + (pingpangPlayer instanceof EngLish));
        System.out.println("basketballCoach instanceof Coach: " + (basketballCoach instanceof Coach));
        System.out.println("pingpangCoach instanceof Coach: " + (pingpangCoach instanceof Coach));
        System.out.println("pingpangCoach instanceof EngLish: " + (pingpangCoach instanceof EngLish));
        System.out.println("test instanceof Training_plan: " + (test instanceof Training_plan));
        System.out.println("test instanceof Training_plan_Adapter: " + (test instanceof Training_plan_Adapter));

        System.out.println("\n========== 全部调试完成！ ==========");
    }
}
