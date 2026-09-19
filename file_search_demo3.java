package com.java46;

import java.io.File;
import java.util.Scanner;

public class file_search_demo3 {
    public static void main(String[] args) {
        Scanner sf = new Scanner(System.in);
        System.out.print("请输入要查找的文件名: ");
        String target = sf.nextLine().trim();

        File root = new File("C:\\Users\\34005\\Desktop\\java-io-test");
        if (!root.isDirectory()) {
            System.out.println("目标文件夹不存在，或不是文件夹: " + root.getAbsolutePath());
            return;
        }

        // 用一个 boolean 把"找到了"这件事从最深处一路带回 main
        boolean found = fileSearch(root, target);
        if (!found) {
            System.out.println("没有找到: " + target);
        }
        sf.close();
    }

    /**
     * @return true 表示在 dir 这棵子树里找到了目标文件
     */
    private static boolean fileSearch(File dir, String filename) {
        File[] files = dir.listFiles();
        if (files == null) {          // 目录无权限访问时 listFiles() 返回 null
            return false;
        }
        for (File temp : files) {
            if (temp.isFile() && temp.getName().equalsIgnoreCase(filename)) {
                System.out.println("找到了 -> " + temp.getAbsolutePath());
                return true;          // 结束整次搜索
            }
            if (temp.isDirectory() && fileSearch(temp, filename)) {
                return true;          // 子树里找到了，继续往上传递
            }
        }
        return false;
    }
}