package com.qiduban.ui;

import javax.swing.*;

public class GameJframe extends JFrame {
//所有关于游戏的内容都写在这里
    public GameJframe(){
        //初始化界面
        Initjframe();

        //初始化功能
        InitFunction();

        //初始化图片
        Initimage();

        //显示界面
        this.setVisible(true);
    }

    //初始化图片
    private void Initimage() {
        //用循环加载15张图片，按4x4网格排列，每格105x105
        for (int i = 0; i < 15; i++) {
            int row = i / 4; //行号
            int col = i % 4; //列号
            //创建一个图片ImageIcon的对象
            ImageIcon icon = new ImageIcon("D:\\Dev\\Projects\\jigsaw3game\\image\\animal\\animal3\\" + (i + 1) + ".jpg");
            //创建一个JLabel对象
            JLabel jLabel = new JLabel(icon);
            //设置图片的位置
            jLabel.setBounds(col * 105, row * 105, 105, 105);
            //把管理容器添加到界面中
            this.getContentPane().add(jLabel);
        }
    }

    private void InitFunction() {
        //初始化菜单
        //创建菜单对象
        JMenuBar jmenubur = new JMenuBar();

        //创建两个功能的对象（功能 关于我们）
        JMenu FunctionJmenu = new JMenu("功能");
        JMenu AboutJmenu = new JMenu("关于我");

        //创建选项下的条目对象
        JMenuItem ReplayItem = new JMenuItem("重新开始");
        JMenuItem ReLoginItem = new JMenuItem("重新登陆");
        JMenuItem CloseItem = new JMenuItem("关闭游戏");
        JMenuItem PayItem = new JMenuItem("打赏");

        //将条目添加到功能中
        FunctionJmenu.add(ReplayItem);
        FunctionJmenu.add(ReLoginItem);
        FunctionJmenu.add(CloseItem);
        AboutJmenu.add(PayItem);

        //将功能添加到菜单中
        jmenubur.add(FunctionJmenu);
        jmenubur.add(AboutJmenu);

        //给界面设置菜单
        this.setJMenuBar(jmenubur);
    }

    private void Initjframe() {
        //设置界面大小
        this.setSize(603,603);

        //设置界面标题
        this.setTitle("王梦燊版拼图v1.0");

        //设置界面置顶
        this.setAlwaysOnTop(true);

        //设置界面居中
        this.setLocationRelativeTo(null);

        //设置关闭模式
        this.setDefaultCloseOperation(3);

        //取消默认的位置放置，只有取消了才会按照xy轴的形式添加组件
        this.setLayout(null);
    }

}
