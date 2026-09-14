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
        file.createNewFile();//真正创建文件而不是简单的创建一个人FILE类型对象
//————————————————————————————————————— 获取文件名称 ——————————————————————————————————————————
        System.out.println(file.getName());
//————————————————————————————————————— 获取文件路径 ——————————————————————————————————————————
        System.out.println("文件路径是： " + file.getPath());//定义文件时写的路径
        System.out.println("文件绝对路径是： " + file.getAbsolutePath());//文件的绝对路径精确到具体的盘
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
                System.out.println(file.getName());
            }

            if (file.isDirectory()) {
                System.out.println("这是一个目录");
                System.out.println(file.getName());//若调用getNAme的对象是个文件夹则返回文件夹的名字
            }
        }
//——————————————————————————————————————— 判断文件大小 ————————————————————————————————————————————
        File file1 = new File("F:\\SteamLibrary\\steamapps\\workshop\\content\\431960\\3800883975\\人付き合いが苦手な未亡人の雪女さんと呪いの指輪 ＃1.mp4");
        long size = file1.length();
        System.out.println(file1.isFile());
        System.out.println(size);//返回文件大小（字节大小）
        System.out.println(file1.lastModified());//返回文件最后的修改时间1789369534103
        time(file1.lastModified());

    }
    public boolean fun2(long year){
        if(year / 4 == 0 || year /400 == 0){
            return true;
        }
      return false;
    };
    public long fun(long day){
        long year = 1970;
        long month = 1;
        long Day = 1;
        if(fun2(year)){
            Day = day / 366;
            year += Day;
            while(Day > 30){
                int i = 1;
                if(i > 12){
                    i =1;
                }switch (i){
                    case 1:Day = Day - 31;
                    case 2:Day = Day - 28;
                    case 3:Day = Day - 31;
                    case 4:Day = Day - 30;
                    case 5:Day = Day - 31;
                    case 6:Day = Day - 30;
                    case 7:Day = Day - 31;
                    case 8:Day = Day - 31;
                    case 9:Day = Day - 30;
                    case 10:Day = Day - 31;
                    case 11:Day = Day - 30;
                    case 12:Day = Day - 31;
                }
                i++;
            }
        }else{
            Day = day / 365;
            year += Day;
        }
        return Day;
    }
    public static void time(long Time){
        long ms = Time % 1000;
        long day = Time / 1000 / 60 / 60 / 24;
        long sec = (Time / 1000) % 86400;
        long hour = sec / 3600;
        long min = sec % 3600 / 60;
        long Sec = sec % 3600 % 60;
        System.out.println(hour + " " + min + " " + Sec);
    }
}
