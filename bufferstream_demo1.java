package com.java47;

import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;

/**
 * 字符缓冲流学习模板（BufferedReader / BufferedWriter）
 * 下面只搭好 try-catch-resource 结构 + 基础的 FileWriter / FileReader，
 * 缓冲流部分留给你自己手动补全（见「二」的步骤提示）。
 */
public class bufferstream_demo1 {
    public static void main(String[] args) {
        /*
            字符缓冲流属于「处理流」，不直接连文件，而是包装基础流，提高读写效率

            public BufferedReader(Reader r)      把字符输入流包装成缓冲输入流
            public BufferedWriter(Writer w)      把字符输出流包装成缓冲输出流

            特有方法：
                BufferedReader : public String readLine()   一次读一行，读到末尾返回 null（返回内容不含换行符）
                BufferedWriter : public void newLine()      写入一个跨平台的换行符

            注意：缓冲流内部自带 8KB 缓冲区，write 之后数据可能还停在缓冲区里没落盘，
                  需要 flush() 或者 close() 才会真正写进文件（关流时会自动 flush）。
        */
        try (
                // 1.创建字符输出流管道，与目标文件接通（文件不存在会自动创建）
                FileWriter fw = new FileWriter("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\bufferstream_demo1.txt");
                //1.1创建缓冲输出流
                BufferedWriter bfw = new BufferedWriter(fw);
                // 2.创建字符输入流管道，与源文件接通（源文件必须已经存在）
                FileReader fr = new FileReader("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\bufferstream_demo1.txt")
        ) {
            // ==================== 一、基础字符流写法（先跑通这段，再改成缓冲流） ====================
            // 写：可以写单个字符、字符串、字符数组的一部分
            bfw.write("hello bufferstream");
            bfw.newLine();//字符缓冲输入流的特性，作用是换行符
            bfw.write("hello java");
            fw.write("\r\n");
            bfw.close();
            // 读：一次读一个字符，返回 -1 表示文件读完了
            int c;
            while ((c = fr.read()) != -1) {
                System.out.print((char)c);
            }
            System.out.println();

            // 提醒：上面这段执行完，fr 已经停在文件末尾了。
            //      正式练习缓冲流时，请把「一」这一整段注释掉，否则下面的 readLine() 会直接返回 null。

            // ==================== 二、缓冲流写法（手动补全） ====================
            // 步骤0：在文件顶部补两个导包
            //        import java.io.BufferedReader;
            //        import java.io.BufferedWriter;
            // 步骤1：包装——缓冲流要写在被包装流的后面，这样 try-with-resource 才会按序一起关掉
            //        BufferedWriter bw = new BufferedWriter(fw);
            //        BufferedReader br = new BufferedReader(fr);
            // 步骤2：写
            //        bw.write("...");
            //        bw.newLine();
            // 步骤3：读
            //        String line;
            //        while ((line = br.readLine()) != null) {
            //            System.out.println(line);
            //        }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
