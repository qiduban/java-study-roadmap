package com.java44;

public class catch_demo1 {
    /*
    * 自己处理(捕获异常)
      格式:
      try{
      可能出现异常的代码;
      * } catch(异常类名 变量名){
      *     异常的处理代码;
      * }
      * */
    //如果出现了ArrayIndexOutOfBoundsException该怎么办
    //此处出现了异常，程序就会在这里创建一个ArrayIndexOutofBoundsException对象
    //new ArrayIndexOutOfBoundsException();
    //拿着这个对象到catch的小括号中对比，看括号中的变量是否可以按收这个对象
    // 如果能被接收，就表示该异常就被捕获(抓住)，执行catch里面对应的代码
    //当catch里面所有的代码执行完毕，继续执行try...catch体系下面的其他代码
    public static void main(String[] args) {
        int []arr = {1,2,3,4,5,6,7,8};
        try{
            System.out.println(arr[100]);
        }catch(ArrayIndexOutOfBoundsException  e){

            System.out.println("索引越界了");
        }catch(ArithmeticException e){
            System.out.println("算数异常");
        }catch(Exception e){
            System.out.println("我是父类");
        };
        System.out.println("看看我执行了吗 ");
    }
}
