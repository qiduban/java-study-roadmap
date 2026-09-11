package com.java45;

import java.io.File;
import java.io.IOException;

public class File_demo1 {
    //File 对象本身并不代表文件里的内容，它只是描述一个文件/目录的路径
    /*public File(String pathname)              根据文件路径创建文件对象
    public File(String parent, String child)    根据父路径名字符串和子路径名字符申创建文件对象
    public File(File parent, String child)      根据父路径对应文件对象和子路径名字符串创建文件对象

    C:\Users\alienware\Desktop
    */
    public static void main(String[] args) throws IOException {
        File file = new File("114514.txt");
        file.createNewFile();
//————————————————————————————————————— 获取文件名称 ——————————————————————————————————————————
        System.out.println(file.getName());
//————————————————————————————————————— 获取文件路径 ——————————————————————————————————————————
        System.out.println("文件路径是： " + file.getPath());
        System.out.println("文件绝对路径是： " + file.getAbsolutePath());
        System.out.println("文件规范路径是： " + file.getCanonicalPath());
//——————————————————————————————————————— 判断文件 ————————————————————————————————————————————
        //判断是否存在
        file.exists();
        //判断是不是文件
        file.isFile();
        //判断是不是目录
        file.isDirectory();
        //例如：
        if (file.exists()) {
            if (file.isFile()) {
                System.out.println("这是一个文件");
            }

            if (file.isDirectory()) {
                System.out.println("这是一个目录");
            }
        }
//——————————————————————————————————————— 判断文件大小 ————————————————————————————————————————————

    }
}
