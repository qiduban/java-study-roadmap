package com.qiduban.base.jdbc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Scanner;

public class revise {
    public static void main(String[] args) throws Exception {
        String url = "jdbc:mysql://127.0.0.1:3307/lyt";
        String name = "root";
        String password = "123456";
        Connection connection = DriverManager.getConnection(url, name, password);
        //
        PreparedStatement preparedStatement = connection.prepareStatement(
                "select id, name, salary from lyt.employee where name = ?");
        Scanner scanner = new Scanner(System.in);
        System.out.println("请输入被查询者的姓名");
        String Name = scanner.nextLine();
        preparedStatement.setString(1,Name);
        ResultSet resultSet = preparedStatement.executeQuery();

        TablePrinter.print(resultSet);

        resultSet.close();
        preparedStatement.close();
        connection.close();
    }
}
