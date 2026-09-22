package com.java47;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class fileoutstream_demo3 {
    public static void main(String[] args) throws Exception {

        /*
         * ==================== try-with-resources 注意点 ====================
         *
         * 1. try-with-resources 是 Java 7 引入的。
         *
         * 2. 只要资源实现了 AutoCloseable 接口，
         *    就可以放到 try(...) 中。
         *
         *    常见的资源：
         *    FileInputStream
         *    FileOutputStream
         *    BufferedInputStream
         *    BufferedOutputStream
         *    BufferedReader
         *    BufferedWriter
         *    Scanner
         *    Connection
         *    PreparedStatement
         *    ResultSet
         *
         * 3. 放到 try(...) 中的资源，在 try 执行结束后会自动调用 close()。
         *
         * 4. 所以不需要再手动写 finally，也不需要手动 close()。
         *
         * 5. 资源必须放在 try(...) 的括号中创建：
         *
         *    try (
         *        FileInputStream is = new FileInputStream(...);
         *        FileOutputStream os = new FileOutputStream(...);
         *    ) {
         *
         *    }
         *
         * 6. try(...) 中可以同时创建多个资源。
         *
         * 7. 多个资源的关闭顺序：
         *
         *    创建顺序：A → B → C
         *    关闭顺序：C → B → A
         *
         *    即：后创建的资源先关闭。
         *
         * 8. 即使 try 中发生异常，资源也会自动关闭。
         *
         * 9. 即使 try 中执行 return，资源也会先 close()，
         *    然后才真正执行 return。
         *
         * 10. 如果 try 中发生异常，同时 close() 又发生异常：
         *
         *     try 中的异常 → 主要异常
         *     close() 的异常 → Suppressed Exception（被抑制异常）
         *
         *     可以通过：
         *
         *     e.getSuppressed()
         *
         *     获取被抑制的异常。
         *
         * 11. try-with-resources 可以看成是：
         *
         *     try + finally + 自动 close()
         *
         *     但实际上编译器会生成更复杂的异常处理代码，
         *     特别是会处理 Suppressed Exception。
         */

        try (

                /*
                 * 注意：
                 * 下面的变量直接在 try(...) 中创建。
                 *
                 * 不需要提前：
                 *
                 * FileOutputStream os = null;
                 *
                 * 也不需要在 finally 中：
                 *
                 * if (os != null) {
                 *     os.close();
                 * }
                 */

                // 1. 创建输出流
                // true：追加写入，新数据放到原数据末尾
                FileOutputStream os = new FileOutputStream(
                        "D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\output_demo1.txt",
                        true
                );

                // 2. 创建输入流
                InputStream is = new FileInputStream(
                        "D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\demo2.txt"
                );

                /*
                 * 3. 创建第二个输入流
                 *
                 * 注意：
                 * 这里的 Is 和上面的 is 是两个不同的变量。
                 *
                 * Java 区分大小写：
                 *
                 * is ≠ Is
                 */
                FileInputStream Is = new FileInputStream(
                        "D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\output_demo1.txt"
                )

        ) {

            /*
             * 这里的 os、is、Is 都可以直接使用。
             *
             * 它们的作用域就是 try-with-resources。
             */

            // 4. 创建 File 对象，获得源文件大小
            File f = new File(
                    "D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\demo2.txt"
            );

            // 5. 将数据存入数组
            byte[] butter = new byte[(int) f.length()];

            /*
             * 从 demo2.txt 中读取数据。
             *
             * 注意：
             * is.read(butter) 返回实际读取的字节数。
             *
             * 对于初学阶段，这种写法可以理解。
             * 实际开发中通常使用 while 循环读取，
             * 防止一次读取不完整。
             */
            is.read(butter);

            // 6. 输出数据到指定文件
            os.write(butter);

            // 7. 写入换行符
            os.write("\r\n".getBytes());

            // 8. 写入 lyt
            os.write("lyt".getBytes());


            // ==================== 读取输出文件 ====================

            /*
             * 注意：
             *
             * 这里有一个非常重要的问题：
             *
             * os 是 FileOutputStream，
             * 上面的 os.write() 数据可能还在缓冲/文件系统处理中。
             *
             * 如果是普通 FileOutputStream，
             * 通常 close() 或 flush() 后才能确保数据写出。
             *
             * 这里为了学习 try-with-resources，
             * 可以理解为最后会自动关闭。
             */

            // 9. 获取输出文件大小
            File F = new File(
                    "D:\\Dev\\Projects\\study_day1\\src\\main\\java\\com\\java47\\output_demo1.txt"
            );

            // 10. 创建数组
            byte[] Butter = new byte[(int) F.length()];

            // 11. 读取输出文件
            Is.read(Butter);

            // 12. 将字节数组转换为字符串
            String s = new String(Butter);

            // 13. 输出内容
            System.out.println(s);


        } catch (IOException e) {

            /*
             * 如果 try 中出现 IOException，
             * 会进入 catch。
             *
             * 即使进入 catch，
             * try(...) 中创建的资源依然会自动关闭。
             */

            e.printStackTrace();

        }

        /*
         * ==================== 这里不需要 finally ====================
         *
         * try-with-resources 会自动帮我们执行：
         *
         * Is.close();
         * is.close();
         * os.close();
         *
         * 而且关闭顺序是：
         *
         * Is → is → os
         *
         * 因为创建顺序是：
         *
         * os → is → Is
         *
         * 后创建的先关闭。
         *
         * 所以原来的：
         *
         * finally {
         *
         *     if (is != null) {
         *         is.close();
         *     }
         *
         *     if (Is != null) {
         *         Is.close();
         *     }
         *
         *     if (os != null) {
         *         os.close();
         *     }
         * }
         *
         * 全部不需要了。
         */
    }
}
