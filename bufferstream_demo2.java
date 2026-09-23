package com.java47;

import java.io.*;
import java.security.KeyStore;

/**
 * 字节缓冲流学习模板（BufferedInputStream / BufferedOutputStream）
 * 「一」基础字节流 FileInputStream / FileOutputStream
 * 「二」字节缓冲流，包装基础流来用
 * 两段各写一个 try-with-resources，互不干扰，可以一次跑完对比结果。
 */
public class bufferstream_demo2 {
    public static void main(String[] args) {
        /*
            字节缓冲流属于「处理流」，不直接连文件，而是包装基础字节流，提高读写效率

            public BufferedInputStream(InputStream in)        包装字节输入流
            public BufferedOutputStream(OutputStream out)     包装字节输出流

            和字符缓冲流的区别：
                字符缓冲流有特有方法 readLine() / newLine()；
                字节缓冲流没有任何特有方法，只是自带 8KB 缓冲区，
                把「反复找磁盘」变成「一次搬一批到内存里慢慢取」。

            注意：BufferedOutputStream 写出的数据也先待在缓冲区，
                  要 flush()、或者 close()（关流会自动 flush）才真正落到文件。
        */

        // ==================== 一、基础字节流：一次读写多个字节 ====================
        try (
                // 1.创建字节输出流管道，与目标文件接通（不存在会自动创建，已存在会先清空）
                OutputStream fos = new FileOutputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\bufferstream_demo2.txt",true);
                //1.1创建缓冲字节输出流，与目标文件接通
                OutputStream bfos = new BufferedOutputStream(fos);
                // 2.创建字节输入流管道，与源文件接通（源文件必须已经存在）——最后一个资源可以省分号
                InputStream fis = new FileInputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\demo2.txt")
                //2.1创建缓冲字节输入流，与源文件接通
        ) {
            // 这里做的是「文件复制」：先从源文件读到 byte[]，再把读到的部分写出去
            byte[] bytes = new byte[1024];
            int len;                 // 本次真正读到的字节个数
            int total = 0;           // 累计复制的字节数
            while ((len = fis.read(bytes)) != -1) {
                fos.write(bytes, 0, len);   // 注意要写 0~len，不能把整个数组全写出去
                total += len;
            }
            System.out.println("一、基础字节流复制完成，bytes = " + total);

            // 记忆点：
            //   read() 返回 -1 就是读完了；一次只读写一个字节效率很低（每次都要跟磁盘打交道），
            //   所以基础字节流靠 byte[] 数组来顶。
            // 坑：不要把 fos 指向 fis 的同一个文件——FileOutputStream 一创建就把文件清空了。
        } catch (Exception e) {
            e.printStackTrace();
        }

        // ==================== 二、字节缓冲流：逐字节读写 ====================
        try (
                // 1.基础字节输出流
                OutputStream fos = new FileOutputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\bufferstream_demo2_buffered.txt");
                // 1.1缓冲字节输出流（包装 fos）——必须写在被包装流的后面，关流时才按倒序一起关掉
                BufferedOutputStream bos = new BufferedOutputStream(fos);
                // 2.基础字节输入流
                InputStream fis = new FileInputStream("D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\demo2.txt");
                // 2.1缓冲字节输入流（包装 fis）
                BufferedInputStream bis = new BufferedInputStream(fis)
        ) {
            // 有了缓冲区，才敢这样一个字节一个字节地读、一个字节一个字节地写
            int b;
            int total = 0;
            while ((b = bis.read()) != -1) {
                bos.write(b);
                total++;
            }
            System.out.println("二、缓冲流复制完成，bytes = " + total);

            // 小实验：把 try-with-resources 改成普通的 try（也就是不关流），
            //        缓冲区没写满时文件里会是空的——这就是 flush / close 存在的意义。
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
