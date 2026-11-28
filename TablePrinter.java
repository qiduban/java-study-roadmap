package com.qiduban.base.jdbc;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * 把查询结果打印成"虚拟表"（带边框的等宽表格）。
 * 列宽自动计算，中文按 2 个字符宽度处理，数值列右对齐。
 */
public final class TablePrinter {

    private TablePrinter() {
    }

    public static void print(ResultSet rs) throws SQLException {
        ResultSetMetaData meta = rs.getMetaData();
        int cols = meta.getColumnCount();

        String[] headers = new String[cols];
        int[] widths = new int[cols];
        boolean[] rightAlign = new boolean[cols];

        for (int i = 0; i < cols; i++) {
            headers[i] = meta.getColumnLabel(i + 1);
            widths[i] = displayWidth(headers[i]);
            rightAlign[i] = isNumeric(meta.getColumnType(i + 1));
        }

        List<String[]> rows = new ArrayList<>();
        while (rs.next()) {
            String[] row = new String[cols];
            for (int i = 0; i < cols; i++) {
                String value = rs.getString(i + 1);
                row[i] = value == null ? "NULL" : value;
                widths[i] = Math.max(widths[i], displayWidth(row[i]));
            }
            rows.add(row);
        }

        printBorder(widths);
        printRow(headers, widths, new boolean[cols]);
        printBorder(widths);
        for (String[] row : rows) {
            printRow(row, widths, rightAlign);
        }
        printBorder(widths);

        if (rows.isEmpty()) {
            System.out.println("查询结果为空（共 0 行）");
        } else {
            System.out.println("共 " + rows.size() + " 行");
        }
    }

    private static void printBorder(int[] widths) {
        StringBuilder sb = new StringBuilder("+");
        for (int width : widths) {
            sb.append("-".repeat(width + 2)).append('+');
        }
        System.out.println(sb);
    }

    private static void printRow(String[] cells, int[] widths, boolean[] rightAlign) {
        StringBuilder sb = new StringBuilder("|");
        for (int i = 0; i < cells.length; i++) {
            int padding = widths[i] - displayWidth(cells[i]);
            String spaces = " ".repeat(padding);
            sb.append(' ');
            if (rightAlign[i]) {
                sb.append(spaces).append(cells[i]);
            } else {
                sb.append(cells[i]).append(spaces);
            }
            sb.append(" |");
        }
        System.out.println(sb);
    }

    private static boolean isNumeric(int sqlType) {
        return switch (sqlType) {
            case Types.TINYINT, Types.SMALLINT, Types.INTEGER, Types.BIGINT,
                 Types.FLOAT, Types.REAL, Types.DOUBLE, Types.NUMERIC, Types.DECIMAL -> true;
            default -> false;
        };
    }

    // 按显示宽度计数：中日韩文字、全角符号占 2 格
    private static int displayWidth(String s) {
        int width = 0;
        for (int i = 0; i < s.length(); ) {
            int cp = s.codePointAt(i);
            width += isWide(cp) ? 2 : 1;
            i += Character.charCount(cp);
        }
        return width;
    }

    private static boolean isWide(int cp) {
        return (cp >= 0x1100 && cp <= 0x115F)
                || (cp >= 0x2E80 && cp <= 0xA4CF)
                || (cp >= 0xAC00 && cp <= 0xD7A3)
                || (cp >= 0xF900 && cp <= 0xFAFF)
                || (cp >= 0xFE30 && cp <= 0xFE4F)
                || (cp >= 0xFF00 && cp <= 0xFF60)
                || (cp >= 0xFFE0 && cp <= 0xFFE6)
                || (cp >= 0x20000 && cp <= 0x3FFFD);
    }
}