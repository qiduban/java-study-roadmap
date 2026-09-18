package com.java45;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;

public class File_demo1 {
    //File 对象本身并不代表文件里的内容，它只是描述一个文件/目录的路径
    /*public File(String pathname)              根据文件路径创建文件对象
    public File(String parent, String child)    根据父路径名字符串和子路径名字符申创建文件对象
    public File(File parent, String child)      根据父路径对应文件对象和子路径名字符串创建文件对象

    C:\Users\alienware\Desktop
    */
    public static void main(String[] args) throws IOException {
        File file = new File("C:\\Users\\34005\\Desktop\\code\\114514.txt");
        File file2 =new File("C:\\Users\\34005\\Desktop\\code\\aaa");
        file.createNewFile();
        boolean a = file2.mkdir();
        System.out.println(a);
        File file3 =new File("C:\\Users\\34005\\Desktop\\code\\aaa\\bb\\cc\\ee");
        boolean b = file3.mkdirs();
        System.out.println(b);
        boolean c =file.delete();
        System.out.println(c);
        File file4 = new File("C:\\Users\\34005\\Desktop\\code\\aaa\\bb\\cc\\ee");
        boolean e = file4.delete();
        System.out.println(e);
        File file5 = new File("C:\\Users\\34005\\Desktop\\code\\aaa\\bb");
        boolean f = file5.delete();
        System.out.println(f);
        //真正创建文件而不是简单的创建一个人FILE类型对象
        //如果文件路径下的文件不存在，则创建成功，返回true
        //----------------存在，则创建失败，返回false
        //-----------的路径错误，则报错返回IOexception
        //createNewFile方法创建的一定是文件，若当前文件路径不包含和后缀则会创建一个没有后缀的文件
        //.mkdir()     make directory创建目录的方法
        //.mkdir       windows的文件路径是唯一的，若当前路径已经存在，则返回创建失败
        //.mkdir      只能创建单级文件夹
        //.mkdirs     可用于创建单级文件夹和多级文件夹
        //.delete     用于删除File类型的对象（不走回收站)
        //.delete     删除文件夹时删除有内容的文件夹会失败，只能删除无内容的文件夹
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
        // ——————————————————————————————————————— 文件获取并遍历 ————————————————————————————————————————————
        //public File[] listfiles()         `    获取路径下的所有内容(包括隐藏内容)
        File file7 =new File("C:\\Users\\34005\\Desktop\\code");
        File []files = file7.listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return true;
            }
        });
        Arrays.stream(files).forEach(System.out::println);
        File []files1 = file7.listRoots();//获取系统盘符
        Arrays.stream(files1).forEach(System.out::println);
        String []arr = file7.list(new FilenameFilter() {
            @Override
            //dir为父级路径
            //name为子级路径
            //返回值：若为true则当前路径保留
            //     ：若为false则当前路径舍弃
            public boolean accept(File dir, String name) {
                String file_name = dir + name;
                File srd = new File(dir ,name);
                if(file_name.endsWith(".txt") && srd.isFile()){
                    return true;
                }
                return false;
            }
        });
        System.out.println(Arrays.toString(arr));
        /*
        • 当调用者File表示的路径不存在时，返回null
        • 当调用者File表示的路径是文件时，返回null
        • 当调用者File表示的路径是一个空文件夹时，返回一个长度为0的数组
        • 当调用者File表示的路径是一个有内容的文件夹时，将里面所有文件和文件夹的路径放在File数组中返回
        • 当调用者File表示的路径是一个有隐藏文件的文件夹时，将里面所有文件和文件夹的路径放在File数组中返回，包含隐藏文件
        ● 当调用者File表示的路径是需要权限才能访问的文件夹时，返回null
        注意file7为一个目录，若你想使用listfile等遍历方法，调用的对象必须是一个目录
         */
    }

}
