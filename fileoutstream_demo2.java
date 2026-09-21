package com.java47;

import java.io.*;
import java.security.DigestOutputStream;
/*
==========================
Java try-catch-finally 知识总结
==========================

一、作用
try-catch-finally 用于处理程序运行时可能出现的异常，
避免程序因为异常而直接崩溃。

--------------------------------
二、基本格式
--------------------------------

try {
    // 可能发生异常的代码
} catch (异常类型 e) {
    // 异常处理代码
} finally {
    // 无论是否发生异常，通常都会执行
}

--------------------------------
三、各部分作用
--------------------------------

1.try
   放可能发生异常的代码。

2.catch
   捕获异常并处理。

   e.printStackTrace();
   // 打印异常详细信息

3.finally
   一般用于释放资源：
   - IO流关闭
   - 数据库连接关闭
   - 网络连接关闭

--------------------------------
四、执行流程
--------------------------------

情况1：没有异常

try
 ↓
finally

情况2：有异常并被捕获

try
 ↓
catch
 ↓
finally

--------------------------------
五、为什么关闭流放 finally
--------------------------------

因为 try 中可能发生异常：

try {
    InputStream is = new FileInputStream("a.txt");

    int a = 10 / 0; // 异常

    is.close(); // 执行不到
}

所以：

finally {
    is.close();
}

这样无论是否异常，流都会关闭。

--------------------------------
六、变量作用域问题
--------------------------------

错误：

try {
    InputStream is = new FileInputStream(...);
}

finally {
    is.close(); // 报错
}

原因：

变量 is 只在 try 的 {} 中有效。

正确：

InputStream is = null;

try {
    is = new FileInputStream(...);
}
finally {
    if (is != null) {
        is.close();
    }
}

--------------------------------
七、为什么判断 null
--------------------------------

可能：

is = new FileInputStream(...);

执行失败：

is == null

直接：

is.close();

会出现：

NullPointerException

所以：

if(is != null){
    is.close();
}

--------------------------------
八、多个 catch
--------------------------------

try {

} catch(IOException e){

} catch(Exception e){

}

规则：

子类异常放前面
父类异常放后面

错误：

catch(Exception e){}
catch(IOException e){}

--------------------------------
九、finally 是否一定执行
--------------------------------

正常情况下：

finally 一定执行。

特殊情况：

System.exit(0);

会直接关闭 JVM，
finally 不执行。

--------------------------------
十、return 与 finally
--------------------------------

public int test(){
    try{
        return 10;
    }finally{
        System.out.println("finally");
    }
}

执行顺序：

return 10
   ↓
执行 finally
   ↓
返回 10

不要在 finally 中写 return：

finally{
    return 20;
}

会覆盖前面的返回值。

--------------------------------
十一、传统 IO 写法
--------------------------------

InputStream is = null;

try {
    is = new FileInputStream("a.txt");

} catch(IOException e){
    e.printStackTrace();

} finally {

    if(is != null){
        try{
            is.close();
        }catch(IOException e){
            e.printStackTrace();
        }
    }
}

--------------------------------
十二、Java7 推荐写法
--------------------------------

try(
    InputStream is =
        new FileInputStream("a.txt")
){

    // 使用流

}catch(IOException e){
    e.printStackTrace();
}

特点：

√ 自动关闭资源
√ 代码更简洁
√ 不需要 finally

--------------------------------
十三、学习口诀
--------------------------------

try：
    放危险代码

catch：
    接住异常

finally：
    释放资源

try-with-resources：
    自动释放资源

--------------------------------
十四、IO 最重要一句话
--------------------------------

谁创建流，谁负责关闭流。

使用完必须 close()，
否则会浪费系统资源。
*/
public class fileoutstream_demo2 {
    public static void main(String[] args) throws Exception{
        //现在创建各种流工具，防止因为变量不在同一个作用域导致对象无法被解析
        FileOutputStream os = null;
        InputStream is = null;
        FileInputStream Is = null;
        try{
            //1.创建输出流
            //FileOutputStream os = new FileOutputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\output_demo1.txt");//覆盖管道：新添加的数据会覆盖掉原数据
            os = new FileOutputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\output_demo1.txt",true);//追加管道：新添加的数据会放在原数据的末尾
            //2.创建file类型对象获得数据大小
            is = new FileInputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\demo2.txt");
            File f =new File("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\demo2.txt");
            //3.将数据存入数组
            byte []butter = new byte[(int)f.length()];
            is.read(butter);
            //5.输出数据到指定文件夹
            os.write(butter);
            os.write("\r\n".getBytes());//io流中的换行符
            os.write("lyt".getBytes());
            //6。读出数据判断是否复制正确
            Is =new FileInputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\output_demo1.txt");
            File F =new File("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\output_demo1.txt");
            byte []Butter = new byte[(int)F.length()];
            Is.read(Butter);
            String s = new String(Butter);
            System.out.println(s);
        }catch (IOException e){
            e.printStackTrace();
        }finally {//finally中不要直接写return等类似的终止方法都则会导致方法直接停止
            //4.判断流是否为空，并关闭输入流
            if(is != null){//防止异常出现在流工具出创建之前，在流工具创建之前is会一直为空加一个判断可以减少报错
                is.close();
            }
            if(Is != null){
                Is.close();
            }
            if(os != null){
                os.close();
            }
        }
    }
}
