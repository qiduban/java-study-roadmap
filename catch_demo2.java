package com.java44;

public class catch_demo2 {
    public static void main(String[] args) {
        int []arr = {1,2,3,4,5,6,7};
        try {
            System.out.println(arr[100]);
            System.out.println("看看我运行了没有1");//在try中识别出可捕获的异常后接下来的代码就不会运行了
        }catch (ArrayIndexOutOfBoundsException e){
            System.out.println("数组越界");
        }catch (NullPointerException e){
            System.out.println("空指针传入");
        }
    }
}
