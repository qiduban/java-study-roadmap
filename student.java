package com.java40_Map.TreeMap;

import java.util.Objects;

public class student {
    public String Name;
    public Integer Age;
    public Integer ID;

    public student(String name, Integer age, Integer ID) {
        Name = name;
        Age = age;
        this.ID = ID;
    }

    public String getName() {
        return Name;
    }

    public void setName(String name) {
        Name = name;
    }

    public Integer getAge() {
        return Age;
    }

    public void setAge(Integer age) {
        Age = age;
    }

    public Integer getID() {
        return ID;
    }

    public void setID(Integer ID) {
        this.ID = ID;
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        student student = (student) o;
        return Objects.equals(Name, student.Name) && Objects.equals(Age, student.Age) && Objects.equals(ID, student.ID);
    }

    @Override
    public int hashCode() {
        return Objects.hash(Name, Age, ID);
    }

    @Override
    public String toString() {
        return "student{" +
                "Name='" + Name + '\'' +
                ", Age=" + Age +
                ", ID=" + ID +
                '}';
    }
}

