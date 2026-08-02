package com.java33;

public interface Wage {//创建接口关键字
    /*接口不能创建对象，接口只是一个方法的规范，不能用于对象的创建
    顶层接口（写在 .java 文件最外层）不能使用 private
    内部接口（只类之中，只能被那个类调用）可以使用private
    | 内容             | 能否 private             |
| -------------- | ---------------------- |
| 顶层接口           | ❌不能                    |
| 类内部接口          | ✅可以                    |
| 接口普通抽象方法       | ❌不能                    |
| 接口 default 方法  | ❌不能（只能 public/default） |
| Java 9+ 接口辅助方法 | ✅可以                    |
| 接口变量           | ❌不能                    |

接口中的变量默认：public static final，不可被改变
接口继承接口
接口之间可以继承：
interface Animal {void eat();}
interface Bird extends Animal {void fly();}
Bird 拥有：
eat()
fly()
接口也可以多继承：
interface C extends A, B {}
这是 Java 允许的

|         | 抽象类            | 接口         |
| ------- | -------------- | ---------- |
| 关键字     | abstract class | interface  |
| 继承方式    | extends        | implements |
| 能否有构造方法 | ✅              | ❌          |
| 成员变量    | 普通变量           | 默认常量       |
| 普通方法    | ✅              | Java8后可以   |
| 抽象方法    | ✅              | ✅          |
| 多继承     | ❌              | 接口可以多继承    |
| 一个类实现数量 | 只能继承一个         | 可以多个       |

Java 接口特点：

使用 interface 定义
类通过 implements 实现
不能创建对象
方法默认是 public abstract
变量默认是 public static final
Java 8 后支持 default 和 static 方法
一个类可以实现多个接口
主要用于规范定义和多态设计

一句话记忆：

抽象类强调“是什么”，接口强调“能做什么”。接口是 Java 实现多继承能力和面向接口编程的核心。
    */
    public void Paying();
}
