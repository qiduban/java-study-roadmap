package com.qiduban.base.jdbc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

/*
 * 【原始代码的 3 个问题，已在下面逐个位置注释】
 *
 * 错误1 (编译不通过)：pad() 方法写在了 class Quick2 的右花括号外面，Java 不允许类外面有方法。
 * 错误2 (编译不通过)：文件末尾多出一个右花括号 }，括号不配对。
 * 错误3 (运行报错)  ：URL 写成了 "jbdc:mysql://"，协议名拼错，报 No suitable driver found for jbdc:mysql://...
 * 附带问题        ：不写端口时默认连 3306，而本机 3306 和 3307 各跑了一个 MySQL 实例，
 *                   两个都有 lyt.employee 但数据不同（1496 行 / 1498 行），显式写端口才不会连错库。
 */
public class Quick2 {
    public static void main(String[] args) throws Exception {
        //1.注册
        Class.forName("com.mysql.cj.jdbc.Driver");

        //建立连接
        // ❌ 原来写成："jbdc:mysql://127.0.0.1/lyt"
        //    ① jbdc → jdbc，协议名前缀错了，驱动认不出来，
        //       运行时抛 No suitable driver found for jbdc:mysql://127.0.0.1/lyt
        //    ② 没写端口 → 默认 3306。本机有两个实例（3306 和 3307）都有 lyt 库，
        //       不写端口就说不清到底连哪个，数据行数都对不上。
        // ✅ 现在：协议写对 + 端口显式写死
        String url = "jdbc:mysql://127.0.0.1:3307/lyt";
        String name = "root";
        String password = "123456";
        Connection connection = DriverManager.getConnection(url, name, password);

        //创建语句
        Statement statement = connection.createStatement();

        //创建查询
        String sql = "select id, name, salary from employee";
        ResultSet resultSet = statement.executeQuery(sql);

        //输出结果
        //处理结果级，遍历resultset收到结果
        //表格边框：id 宽6、name 宽21、salary 宽10，两侧各留1个空格
        String line = "+--------+-----------------------+------------+";
        System.out.println(line);
        System.out.printf("| %-6s | %s | %10s |%n", "id", pad("name", 21), "salary");
        System.out.println(line);
        while(resultSet.next()){
            int id = resultSet.getInt("id");
            String name1 = resultSet.getString("name");
            // 小提示：salary 是 decimal(10,2)，严格来说应该用 getBigDecimal("salary")，
            // 用 double 处理金额会有二进制浮点的精度隐患（当前数据看不出差别，属于写法习惯问题）。
            double salary = resultSet.getDouble("salary");
            System.out.printf("| %6d | %s | %10s |%n", id, pad(name1, 21), String.format("%.2f", salary));
        }
        System.out.println(line);

        resultSet.close();
        statement.close();
        connection.close();
    }
    // ❌ 原来这一行的位置：main() 之后先有一个 }，把 class Quick2 提前闭合了，
    //    pad() 就落在了类的外面 —— 编译报
    //    "class, interface, enum, or record expected" 和 "illegal start of expression"。
    // ✅ 现在：类只在这里闭合一次，pad() 被收进类内部，文件末尾那个多余的 } 也删掉了。

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