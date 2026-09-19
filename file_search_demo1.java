package com.java46;

import java.io.File;
import java.io.IOException;
import java.util.Scanner;

public class file_search_demo1 {
    public static void main(String[] args) throws IOException {
        Scanner sf =new Scanner(System.in);
        String target = sf.next();
        //目标文件夹
        File java_io_test = new File("C:\\Users\\34005\\Desktop\\java-io-test");
        //确定所查找文件为文件夹
        if (java_io_test.isDirectory()){
            FileSearch(java_io_test,target);
        }else{
            System.out.println("? :(");
        }
    }
    public static void FileSearch(File dir , String Filename) throws IOException {
        if(dir == null || !dir.exists()){
            System.out.println("! :(");
            return;
        }
        File []files = dir.listFiles();//提取每级文件夹中的所有变量
        if(files != null && files.length > 0){
            for(File temp : files){//遍历确定文件是否是目标文件夹，以及判断文件夹是否为空，若否则重复上述操作
                if(temp.isFile() && temp.getName().contains(Filename)){
                    System.out.println("! :)" + temp.getAbsolutePath());
//                    Runtime runtime = Runtime.getRuntime();
//                    runtime.exec(temp.getAbsolutePath());
                    return;
                }
                else{
                    FileSearch(temp,Filename);
                }
            }
        }
    }
}
