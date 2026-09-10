package com.java44;

public class throws_throw_demo1 {
    public static void main(String[] args) {
        /*
         * ==================== throw 和 throws 的区别 ====================
         *
         * 1. throw：主动抛出一个异常
         *
         *    throw new RuntimeException("出错了");
         *
         *    特点：
         *    - 写在方法体内部
         *    - 后面跟“异常对象”
         *    - 真正执行抛出异常的动作
         *    - 一次只能抛出一个异常对象
         *
         *
         * 2. throws：声明方法可能抛出的异常
         *
         *    public void test() throws IOException {
         *    }
         *
         *    特点：
         *    - 写在方法声明处
         *    - 后面跟“异常类型”
         *    - 不负责真正抛出异常，只是声明
         *    - 可以声明多个异常
         *    - 通常把异常交给调用者处理
         *
         *
         * 3. 最简单的记忆：
         *
         *    throw  = 真正“抛”异常
         *    throws = 声明“可能抛”哪些异常
         *
         *
         * 4. 二者可以同时使用：
         *
         *    public void test() throws IOException {
         *        throw new IOException("文件读取失败");
         *    }
         *
         *    throws IOException：
         *    表示这个方法可能抛出 IOException
         *
         *    throw new IOException(...)：
         *    表示现在真正抛出一个 IOException 对象
         *
         * ==============================================================
         */
        //int []arr = {1,2,3,4,5,6,345,23,5234,2332,4};
        int []arr = {};
        int max = max(arr);
        System.out.println(max);
    }
    public static int max(int []arr){
        int MAx = 0;
        if(arr == null){
            throw new NullPointerException();//throw会结束方法下面的语句就不会被执行了
        }
        if(arr.length == 0){
            throw new ArrayIndexOutOfBoundsException();
        }
        for (int i = 0 ; i < arr.length ; i++) {
            if(MAx < arr[i]){
                MAx = arr[i];
            }
        }
        System.out.println("看看我运行了吗");
        return MAx;
    }
}
