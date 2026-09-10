package com.java44;

public class girlfriend {
    private String Name;
    private String Age;

    public girlfriend(String name, String age) {
        Name = name;
        Age = age;
    }
    public girlfriend(){

    }
    public String getName() {
        return Name;
    }

    public void setName(String name) {
        Name = name;
    }

    public String getAge() {
        return Age;
    }

    public boolean setAge(String age) {
        for (int i = 0 ; i < age.length() ; i++){
            if(age.charAt(i) < '0' || age.charAt(i) >'9' ){
                throw new NegativeArraySizeException();
            } else if(Integer.parseInt(age) > 40 || Integer.parseInt(age) < 18) {
                throw new ArrayIndexOutOfBoundsException();
            }
        }
        Age = age;
        return true;
    }
}

