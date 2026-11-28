package com.qiduban.base.jdbc;

import java.sql.*;
import java.util.Properties;
import java.util.logging.Logger;

/*
 * 【纯练习用类，注释里的【知识点】按 JDBC 执行顺序排列】
 * 顺序：注册驱动 → 获取连接(1) → 创建语句(3) → 执行查询(4) → 遍历结果(5) → 关资源(6)
 *
 * 命名提醒：类名建议首字母大写（Quick），因为 Java 约定类名用大驼峰；
 *          现在类名是小写 quick，能编译能跑，但不符合规范，IDEA 也会给黄色提示。
 */
public class quick {
    public static void main(String[] args) throws Exception{
        //注册驱动
        // (从JDK6开始，不再需要显式地调用Class.forName()来加载JDBC驱动程序，只要在类路径中集成了对应
        //的jar文件，会自动在初始化时注册驱动程序。)
        //Class.forName("com.mysql.cj.jdbc.Driver");

        /*
         * 【知识点 0 · 为什么可以不写 Class.forName】
         * JDBC 4.0(JDK6) 起引入了 SPI 机制：驱动 jar 里的
         *   META-INF/services/java.sql.Driver
         * 文件写了自己的驱动类名，DriverManager 初始化时会自动把它扫出来注册。
         * 所以只要依赖在 classpath 上（Maven 已引入），Class.forName 可以省略。
         * 老代码/老教程里那行 Class.forName 是 JDBC 3.0 时代的必需动作，留着也无害。
         */

        /*DriverManager.registerDriver(new Driver() {
            @Override
            public Connection connect(String url, Properties info) throws SQLException {
                return null;
            }

            @Override
            public boolean acceptsURL(String url) throws SQLException {
                return false;
            }

            @Override
            public DriverPropertyInfo[] getPropertyInfo(String url, Properties info) throws SQLException {
                return new DriverPropertyInfo[0];
            }

            @Override
            public int getMajorVersion() {
                return 0;
            }

            @Override
            public int getMinorVersion() {
                return 0;
            }

            @Override
            public boolean jdbcCompliant() {
                return false;
            }

            @Override
            public Logger getParentLogger() throws SQLFeatureNotSupportedException {
                return null;
            }
        });手动注册driver*/
        //获取连接对象
        /*
         * 【知识点 1 · DriverManager：驱动管理器】
         * 要执行 SQL 得先有一条到数据库的"通道"，DriverManager 就是负责开通道的。
         * 它是 java.sql 下的工具类，不能 new，直接用静态方法。
         *
         * DriverManager.getConnection(url, user, password) 三个参数：
         *   url      —— 连接串，格式 jdbc:子协议://主机:端口/数据库名?参数
         *               · jdbc      固定协议前缀（拼成 jbdc 驱动就不认，报 No suitable driver found）
         *               · mysql     子协议，交给 com.mysql.cj.jdbc.Driver 解析
         *               · 127.0.0.1 主机（写 localhost 可能走 IPv6/socket，用 IP 更稳）
         *               · 3307      端口，MySQL 默认 3306，不写就用默认值
         *               · /lyt      连上后默认使用的库，之后 SQL 里就不用每次写 lyt.employee
         *   user     —— 账号
         *   password —— 密码
         *
         * 返回值 java.sql.Connection（知识点 2），失败抛 SQLException。
         */
        String url = "jdbc:mysql://127.0.0.1:3307/lyt";
        String name = "root";
        String password = "123456";
        Connection connection = DriverManager.getConnection(url,name,password);

        /*
         * 【知识点 2 · Connection：连接对象 / 会话】
         * 代表"我和数据库之间的这条会话"，是后续所有操作的源头——语句从它造，事务靠它控制。
         * 常用 API：
         *   createStatement()            创建 Statement（本文件用的）
         *   prepareStatement(sql)        创建 PreparedStatement（预编译、防 SQL 注入，开发首选）
         *   setAutoCommit(false)/commit()/rollback()   手动管事务
         *   close()                      关闭连接，释放底层 socket 和服务端会话
         *
         * 注意：连接是贵重资源，服务端并发连接数有限（默认几百），
         * 不关就会连接泄漏，跑久了报 Too many connections。
         */

        //获取执行sql语句的对象
        /*
         * 【知识点 3 · Statement：SQL 执行器】
         * connection.createStatement() 造一个"发 SQL 的载体"，它本身不带 SQL。
         * 三个执行方法按"返回什么"区分（最容易混的地方）：
         *   executeQuery(sql)   → 只跑 SELECT，返回 ResultSet        ← 本文件用的
         *   executeUpdate(sql)  → 跑 INSERT/UPDATE/DELETE，返回 int（影响行数）
         *   execute(sql)        → 万能，返回 boolean（true=结果是 ResultSet，false=是更新计数）
         * 用错方法会抛 SQLException，比如拿 executeQuery 去跑 delete。
         *
         * 实际开发用 PreparedStatement 的原因：Statement 靠字符串拼接 SQL，
         * 参数里塞 ' or '1'='1 就能改掉语句语义（SQL 注入）；
         * PreparedStatement 用 ? 占位 + setXxx 传参，参数只当值、不当语法，天然免疫。
         */
        Statement statement = connection.createStatement();
   
        //编写sql语句并执行并返回所需结果

        String sql = "select id, name, salary from employee order by id";

        /*
         * 【知识点 4 · ResultSet：结果集】
         * executeQuery 返回的 ResultSet 就是一张"虚拟表"：行是记录，列是 select 出来的字段。
         * 但它是流式的——内部有个游标(cursor)，一开始停在"第一行之前"，要靠 next() 才能动。
         *
         *   resultSet.next()      游标下移一行：有数据返回 true，到末尾返回 false → 所以当 while 条件
         *   resultSet.getXxx(...) 取当前行的列值，参数可用列名("name")或列序号(2，从 1 开始)
         *     · getInt / getString / getDouble / getBigDecimal / getDate ...
         *     · 列名写错 → SQLException: Column 'xxx' not found（之前踩的就是这个：写成 name1）
         *     · 没在 select 里查的列也取不到，报同样的错
         *
         * 默认类型 TYPE_FORWARD_ONLY（只能往前翻）+ CONCUR_READ_ONLY（只读），
         * 所以不能倒着遍历，也不能拿结果集直接改库。
         */
        ResultSet resultSet = statement.executeQuery(sql);

        //处理结果级，遍历resultset收到结果
        /*
         * 【知识点 5 · 按列类型选 getXxx】
         * 表结构：id int、name varchar(50)、salary decimal(10,2)
         *   id     int           → getInt
         *   name   varchar(50)   → getString
         *   salary decimal(10,2) → getBigDecimal 最严谨（金额用 double 会有二进制浮点精度问题）
         * 这里统一交给 TablePrinter 打印：它内部按列类型自动取值、自动算列宽并对齐。
         * 想手写遍历时，再按上面的类型选 getXxx。
         */
        TablePrinter.print(resultSet);

        //释放资源(先开后关)
        /*
         * 【知识点 6 · 释放资源：先开后关】
         * 顺序 ResultSet → Statement → Connection，与打开顺序相反。
         * 因为 Statement 依赖 Connection 活着、ResultSet 又是 Statement 的产物，
         * 先关底层会让上层变成悬空引用。
         * close() 只是关闭这条通道，不代表对象被回收（close 和 GC 是两件事）。
         *
         * 更安全的写法是 try-with-resources（三者都实现了 AutoCloseable）：
         *   try (Connection c = DriverManager.getConnection(url, u, p);
         *        Statement s = c.createStatement();
         *        ResultSet rs = s.executeQuery(sql)) { ... }
         * 即使中途抛异常也会自动关闭，不必手写 finally。
         */
        resultSet.close();
        statement.close();
        connection.close();
    }
}
