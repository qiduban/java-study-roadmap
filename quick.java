package com.qiduban.base.jdbc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class quick {
    public static void main(String[] args) throws Exception{
        //注册驱动
        Class.forName("com.mysql.cj.jdbc.Driver");

        //获取连接对象
        String url = "jdbc:mysql://127.0.0.1:3307/lyt";
        String name = "root";
        String password = "123456";
        Connection connection = DriverManager.getConnection(url,name,password);

        //获取执行sql语句的对象
        Statement statement = connection.createStatement();
   
        //编写sql语句并执行并返回所需结果
        String sql = "select id, name, salary from employee order by id";
        ResultSet resultSet = statement.executeQuery(sql);

        //处理结果级，遍历resultset收到结果
        //表格边框：id 宽6、name 宽21、salary 宽10，两侧各留1个空格
        String line = "+--------+-----------------------+------------+";
        System.out.println(line);
        System.out.printf("| %-6s | %s | %10s |%n", "id", pad("name", 21), "salary");
        System.out.println(line);
        while(resultSet.next()){
            int id = resultSet.getInt("id");
            String name1 = resultSet.getString("name");
            double salary = resultSet.getDouble("salary");
            System.out.printf("| %6d | %s | %10s |%n", id, pad(name1, 21), String.format("%.2f", salary));
        }
        System.out.println(line);

        //释放资源(先开后关)
        resultSet.close();
        statement.close();
        connection.close();
    }

    //按"显示宽度"右补空格，中文算2格，保证中文姓名也能对齐
    private static String pad(String s, int width) {
        int len = 0;
        for (char c : s.toCharArray()) {
            len += (c > 0x2E80) ? 2 : 1;
        }
        StringBuilder sb = new StringBuilder(s);
        for (int i = len; i < width; i++) {
            sb.append(' ');
        }
        return sb.toString();
    }
}
