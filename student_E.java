package com.java39_E;

public class student_E <E>{
    private E Name;
    private E Age;

    public E getName() {
        return Name;
    }

    public void setName(E name) {
        Name = name;
    }

    public E getAge() {
        return Age;
    }

    public void setAge(E age) {
        Age = age;
    }
    @Override
    public boolean equals(Object obj){

        student_E s = (student_E) obj;

        return this.Name.equals(s.Name)
                &&
                this.Age == s.Age;

    }
}
