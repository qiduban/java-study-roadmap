package com.java33;

class Teacher extends Person implements Wage{//调用接口关键字
    public Teacher(){
        super();
    }            //注意！！！先 extends，后 implements，先继承后接口
    public Teacher(String Name , int Age , String Gander , String Adress){
        super(Name , Age , Gander , Adress);
    }
    @Override
    public void work(){
        System.out.println("正在教书 ");
    }
    public void Paying(){
        System.out.println("发工资");
    }

}
