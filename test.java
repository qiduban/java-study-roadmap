package com.java35;

import java.util.Scanner;

public class test {
    public static void main(String[] args) {
        Scanner sf =new Scanner(System.in);
        Car C = new Car("Su7",2,"Green");
        C.show();
        new Grade(){//
            @Override
            public void Findway(){
                System.out.println("正在导航");
            }
        };
    }
}
/*
1.Outer outer = new Outer();
  Outer.Inner inner = outer.new Inner();
  inner.print();
  直接创建内部类的方法
  ！！！！静态内部类（static inner class）
  使用：
  class Outer {
      static class Inner {
      }
  }
  特点：
  静态内部类属于外部类本身，不依赖外部类对象。
  创建：
  Outer.Inner inner =
          new Outer.Inner();
  不需要：
  new Outer()

2.普通内部类可以直接访问外部类的变量，即便变量是以private修饰的
  ！！！！！！！但静态内部类无法访问外部类的变量（静态方法和静态变量可以 例子：outer.变量/方法），因为访问外部类需要outer.this.变量名，而但是静态内部类没有 Outer.this！！！！！！！！

3.3. 局部内部类
定义在方法里面：
class Outer {
    void test(){
        class Inner {
            void show(){
                System.out.println("内部类");
            }
        }
        Inner i = new Inner();先创建再使用
        i.show();
    }
}
特点：
作用范围只在方法内部
外部无法访问（
类似于普通方法内创建的变量生存周期，之存在于当前方法中
void test(){
    int a = 10;
}
）

4.
* */