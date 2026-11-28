package com.qiduban.base.jdbc;

import java.sql.*;
import java.util.Scanner;

public class JDBCprepared {
    public static void main(String[] args) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");

        //建立连接
        String url = "jdbc:mysql://127.0.0.1:3307/lyt";
        String name = "root";
        String password = "123456";
        Connection connection = DriverManager.getConnection(url, name, password);
        System.out.println("请输入查询员工的姓名");
        Scanner sc = new Scanner(System.in);
        String Name = sc.nextLine();
        //创建语句
        //connection.createStatement();

        //【prepareStatement 为什么能防注入】关键在于"先编译、后传值"两步分开：
        //  第 1 步：带 ? 的 SQL 模板先被送到数据库，数据库把它编译成执行计划，
        //          SQL 的语法结构就此固定 —— 此时还不知道用户要查什么。
        //  第 2 步：setString(1, Name) 只是把 Name 当成"一个字符串值"传进去，
        //          驱动会自动给它加引号、转义里面的 ' 和 \。
        //  所以即使用户输入  王梦燊' or '1'='1
        //  最终也只是一个普通的名字字符串，or '1'='1 不会被当成 SQL 语法，查不到东西。
        //  对比下面 createStatement 的写法：SQL 是拼字符串拼出来的，用户输入直接长进了 SQL 里，
        //  引号一闭合就能篡改语义 —— 这就是注入的根源。
        PreparedStatement pstmt = connection.prepareStatement(
                "select id, name, salary from employee where employee.name = ?");

        pstmt.setString(1, Name);   // 把用户输入填进第 1 个 ?，不会有 SQL 注入
        ResultSet resultSet = pstmt.executeQuery();

        //输出结果（TablePrinter 自动算列宽、处理中文对齐，空结果也会给出提示）
        TablePrinter.print(resultSet);

        resultSet.close();
        pstmt.close();
        connection.close();

    }
}
