package com.qiduban.base.jdbc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Scanner;

public class Quick2 {
    public static void main(String[] args) throws Exception {
        //1.注册
        Class.forName("com.mysql.cj.jdbc.Driver");

        //建立连接
        String url = "jdbc:mysql://127.0.0.1:3307/lyt";
        String name = "root";
        String password = "123456";
        Connection connection = DriverManager.getConnection(url, name, password);
        Scanner sc = new Scanner(System.in);
        String Name = sc.nextLine();
        //创建语句
        Statement statement = connection.createStatement();

        //创建查询(但是Statement接口在执行sQL语句时，会产生sQL注入攻击问题)
        String sql = "select id, name, salary from employee where employee.name = ' " + Name + "'";
        //若Name的内容"王梦燊" or '1' = '1 则数据库会输出所有记录，这就是sql注入

        //先把你输入的原始内容、以及拼接后真正发给数据库的SQL打印出来，方便对照
        System.out.println("输入内容: " + Name);
        System.out.println("实际执行SQL: " + sql);
        System.out.println();

        ResultSet resultSet = statement.executeQuery(sql);

        //输出结果（统一用 TablePrinter 打印成虚拟表）
        TablePrinter.print(resultSet);

        resultSet.close();
        statement.close();
        connection.close();
    }
}