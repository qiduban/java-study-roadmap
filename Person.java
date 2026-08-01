package com.java33;

public abstract class Person {//有abstract修饰为抽象类，抽象类不能被直接创建即（Person p = new Person()错误）
                              //抽象类不能被final修饰，因为抽象类必须被继承，而final会阻止继承
    /*
    | 特点         | 说明        |
| ---------- | --------- |
| 不能 new     | 不能直接创建对象  |
| 可以有构造方法    | 子类创建对象时调用 |
| 可以有普通方法    | 提供公共实现    |
| 可以有抽象方法    | 强制子类实现    |
| 子类必须实现抽象方法 | 除非子类也是抽象类 |
| 可以有成员变量    | 和普通类一样    |
| 不能 final   | 因为需要继承    |
    */
    private String Name;
    public int Age;
    public String Gander;
    public String address;

    public String getName() {
        return Name;
    }

    public void setName(String name) {
        Name = name;
    }

    public int getAge() {
        return Age;
    }

    public void setAge(int age) {
        Age = age;
    }

    public String getGander() {
        return Gander;
    }

    public void setGander(String gander) {
        Gander = gander;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }
    public void Sleep(){
        System.out.println("在睡觉");
    }
    public abstract void work();//抽象方法不能有自己的主体（没有{}括号里内容），强制子类重写方法
}
