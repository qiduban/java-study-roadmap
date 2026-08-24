package com.java39_Set;

import java.util.Objects;

public class student implements Comparable<student>{
    public String Name;
    public int Age;

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

    public student(String name, int age) {
        Name = name;
        Age = age;
    }

    @Override
    public String toString() {
        return "student{" +
                "Name='" + Name + '\'' +
                ", Age=" + Age +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        student student = (student) o;
        return Age == student.Age && Objects.equals(Name, student.Name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(Name, Age);
    }

    @Override
    public int compareTo(student o) {
        System.out.println("this:" + this.Age);
        System.out.println("o:" + o.Age);
        int result = this.getAge() - o.getAge();
        return result;
    }
}
