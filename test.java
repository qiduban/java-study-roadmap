/*
 * 匿名内部类：
 *
 * 1. 没有名字的内部类。
 * 2. 本质是一个匿名子类对象或接口实现对象。
 * 3. 创建对象时同时定义类。
 * 4. 常用于接口实现、抽象类继承、回调、线程。
 * 5. 可以访问外部类成员。
 * 6. 访问局部变量时必须是final或有效final。
 *
 * 语法：
 *
 * new 接口/父类(){
 *
 *     重写方法
 *
 * };
 */
package com.java35;

import java.util.Scanner;

public class test {
    public static void main(String[] args) {
        Scanner sf =new Scanner(System.in);
        Car C = new Car("Su7",2,"Green");
        C.show();
        Grade G =  new Grade(){//
            @Override
            public void Findway(){
                System.out.println("Grade 正在导航");
            }
        };
        G.Findway();
        Gps g = new Gps(){
          @Override
          public void The_Way(){
              System.out.println("Gps 正在为您导航");
          }
        };new Gps(){
          @Override
          public void The_Way(){
              System.out.println("Gps 正在为您导航");
          }
        };
        g.The_Way();
        C.Find_way(new Grade(){
            @Override
            public void Findway(){
                System.out.println("Grade 正在导航");
            }
        }
        );
        new Gps(){
            @Override
            public void The_Way(){
                System.out.println("Gps 正在为您导航");
            }
        }.The_Way();//匿名内部类相当与对一个接口/类的继承/实现,所以相当于生成了一个对象，所以本身可以直接调用接口/类方法或者变量
        /*
         * 匿名内部类作为方法参数
         *
         * 1. 概念：
         *
         *    匿名内部类可以直接作为方法的参数传递。
         *    不需要提前定义一个实现类或子类，
         *    而是在调用方法时临时创建对象。
         *
         *
         * 2. 基本语法：
         *
         *    方法名(new 接口/父类() {
         *
         *        // 重写方法
         *
         *    });
         *
         *
         * 3. 本质：
         *
         *    例如：
         *
         *    test(new Animal(){
         *
         *        public void eat(){
         *
         *        }
         *
         *    });
         *
         *
         *    编译器实际上类似生成：
         *
         *    class Test$1 implements Animal {
         *
         *        public void eat(){
         *
         *        }
         *
         *    }
         *
         *    然后：
         *
         *    Animal a = new Test$1();
         *
         *    test(a);
         *
         *
         * 4. 使用条件：
         *
         *    方法参数类型必须是：
         *
         *    （1）接口
         *
         *         void test(Runnable r)
         *
         *
         *    （2）普通父类
         *
         *         void test(Person p)
         *
         *
         *    （3）抽象类
         *
         *         void test(Animal a)
         *
         *
         * 5. 常见使用场景：
         *
         *    （1）线程
         *
         *         new Thread(new Runnable(){
         *
         *             public void run(){
         *
         *             }
         *
         *         });
         *
         *
         *    （2）回调
         *
         *         方法执行完成后，
         *         通过接口对象调用指定方法。
         *
         *
         *    （3）事件监听
         *
         *         例如按钮点击事件：
         *
         *         button.addListener(new Listener(){
         *
         *         });
         *
         *
         *    （4）集合排序
         *
         *         Comparator匿名实现：
         *
         *         list.sort(new Comparator(){
         *
         *         });
         *
         *
         * 6. 优点：
         *
         *    （1）减少类的数量。
         *
         *    （2）代码逻辑和使用位置放在一起。
         *
         *    （3）适合只使用一次的对象。
         *
         *    （4）方便实现回调机制。
         *
         *
         * 7. 缺点：
         *
         *    （1）无法重复使用。
         *
         *    （2）代码过长时可读性降低。
         *
         *
         * 8. 与普通实现类比较：
         *
         *
         *    普通实现类：
         *
         *    class Dog implements Animal {
         *
         *        public void eat(){
         *
         *        }
         *
         *    }
         *
         *    test(new Dog());
         *
         *
         *    匿名内部类：
         *
         *    test(new Animal(){
         *
         *        public void eat(){
         *
         *        }
         *
         *    });
         *
         *
         *    匿名内部类适合：
         *        一次性、小逻辑实现
         *
         *
         * 9. 与Lambda关系：
         *
         *    如果匿名内部类实现的是函数式接口，
         *    Java 8以后可以使用Lambda简化。
         *
         *
         *    匿名内部类：
         *
         *    new Runnable(){
         *
         *        public void run(){
         *
         *        }
         *
         *    }
         *
         *
         *    Lambda：
         *
         *    () -> {
         *
         *    }
         *
         *
         * 总结：
         *
         *    匿名内部类作为方法参数 =
         *
         *    创建一个临时对象
         *           ↓
         *    传递给方法
         *           ↓
         *    方法通过接口/父类调用对象的方法
         *
         */
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
  ！！！！！！！但静态内部类无法访问外部类的变量（静态方法和静态变量可以 例子：outer.变量/方法），
  因为访问外部类需要outer.this.变量名，而但是静态内部类没有 Outer.this！！！！！！！！

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
/*
 * 匿名内部类（Anonymous Inner Class）
 *
 * 1. 概念：
 *    匿名内部类是没有名字的内部类。
 *    它本质上是一个没有显式声明类名的子类对象或接口实现类对象。
 *
 * 2. 语法：
 *
 *    new 父类/接口() {
 *
 *        // 重写方法
 *
 *    };
 *
 *    注意：最后需要加分号。
 *
 *
 * 3. 使用场景：
 *    （1）实现接口
 *         当一个接口只需要使用一次时，可以不用创建单独的实现类。
 *
 *    （2）继承抽象类
 *         可以直接创建抽象类的匿名子类对象，并实现抽象方法。
 *
 *    （3）继承普通类
 *         可以临时修改或扩展某个类的方法。
 *
 *    （4）事件监听、回调、多线程等场景中经常使用。
 *
 *
 * 4. 匿名内部类特点：
 *
 *    （1）没有类名，无法重复创建对象。
 *
 *    （2）创建对象和定义类同时完成。
 *
 *    （3）只能使用一次，适合简单逻辑。
 *
 *    （4）可以访问外部类成员（包括private成员）。
 *
 *    （5）访问局部变量时，变量必须是final或有效final。
 *
 *
 * 5. 匿名内部类访问外部变量：
 *
 *    int num = 10;
 *
 *    new Runnable() {
 *
 *        public void run() {
 *            System.out.println(num);
 *        }
 *
 *    };
 *
 *    num不能被修改，否则编译错误。
 *
 *
 * 6. 匿名内部类的本质：
 *
 *    代码：
 *
 *    Animal a = new Animal() {
 *
 *        public void sound(){}
 *
 *    };
 *
 *    编译器会自动生成类似：
 *
 *    class Test$1 extends Animal {
 *
 *        public void sound(){}
 *
 *    }
 *
 *    所以匿名内部类本质上还是一个类。
 *
 *
 * 7. 匿名内部类和普通内部类区别：
 *
 *    普通内部类：
 *        - 有名字
 *        - 可以多次创建
 *        - 适合复杂逻辑
 *
 *    匿名内部类：
 *        - 没有名字
 *        - 通常使用一次
 *        - 适合简单实现
 *
 *
 * 8. Java 8之后：
 *
 *    如果匿名内部类实现的是函数式接口，
 *    可以使用Lambda表达式简化。
 *
 *    例如：
 *
 *    new Runnable(){
 *
 *        public void run(){
 *
 *        }
 *
 *    };
 *
 *    可以写成：
 *
 *    () -> {
 *
 *    };
 *
 *
 * 总结：
 *
 *    匿名内部类 = 临时创建一个没有名字的子类/实现类对象。
 *
 *    常用于：
 *    接口实现、抽象类继承、线程、监听器、回调。
 */