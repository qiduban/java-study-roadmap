package com.java44;

public class throwable_demo1 {
    public static void main(String[] args) {
//        public String getMessage()      返回throwable的详细消息字符串
//        public string tostring()        抛出问题的简短描述
//        public string PrintstackTrace   把异常错误信息处处到控制台
        int arr[] = {1,2,3,4,5,6,7,8,9};
        try {
            System.out.println(arr[1000]);
        } catch (ArrayIndexOutOfBoundsException e) {
//            String Message = e.getMessage();
//            System.out.println(Message);
//            System.out.println(e.toString());
            e.printStackTrace();//将异常的所有信息以红色字体打印在控制台，并且不会结束虚拟机
            System.err.println("123");//专门用于打印错误信息的输出语句，打印时字体为红色
        }
        System.out.println("114514");
    }
}
