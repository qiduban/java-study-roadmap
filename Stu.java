package com.java40_Map;

import java.util.Objects;

public class Stu {
    public String Name;
    public int Age;
    public int Grade_Chinese = 0;
    public int Grade_Math = 0;
    public int Grade_English = 0;
    public int all = 0;

    public Stu(String name, int age, int grade_Chinese, int grade_Math, int grade_English) {
        Name = name;
        Age = age;
        Grade_Chinese = grade_Chinese;
        Grade_Math = grade_Math;
        Grade_English = grade_English;
        this.all = Grade_Chinese + Grade_Math + Grade_English;

    }

    public String getName() {
        return Name;
    }

    public void setName(String name) {
        Name = name;
    }

    public int getAge() {
        return Age;
    }

    public void setAge(int age) {
        Age = age;
    }

    public int getGrade_Chinese() {
        return Grade_Chinese;
    }

    public void setGrade_Chinese(int grade_Chinese) {
        Grade_Chinese = grade_Chinese;
    }

    public int getGrade_Math() {
        return Grade_Math;
    }

    public void setGrade_Math(int grade_Math) {
        Grade_Math = grade_Math;
    }

    public int getGrade_English() {
        return Grade_English;
    }

    public void setGrade_English(int grade_English) {
        Grade_English = grade_English;
    }

    public int getAll() {
        return all;
    }

    public void setAll(int all) {
        this.all = all;
    }

    @Override
    public String toString() {
        return "Stu{" +
                "Name='" + Name + '\'' +
                ", Age=" + Age +
                ", Grade_Chinese=" + Grade_Chinese +
                ", Grade_Math=" + Grade_Math +
                ", Grade_English=" + Grade_English +
                ", all=" + all +
                '}' + '\n';
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        Stu stu = (Stu) o;
        return Age == stu.Age && Grade_Chinese == stu.Grade_Chinese && Grade_Math == stu.Grade_Math && Grade_English == stu.Grade_English && all == stu.all && Objects.equals(Name, stu.Name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(Name, Age, Grade_Chinese, Grade_Math, Grade_English, all);
    }
}



