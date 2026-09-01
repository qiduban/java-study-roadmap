package com.java41;

public class demo1 {
    public static int GetSum(int... a){
    int Sum = 0;
    for(int sum : a){
        Sum += sum;
    }
    return Sum;
}
    public static void main(String[] args) {
        int sum = GetSum(1,2,3,4,5,6);
        System.out.println(sum);
    }
    /*
     * ==================== Java 可变参数（Varargs）====================
     *
     * 1. 基本语法
     *    类型... 参数名
     *
     *    public static void test(int... nums) {
     *    }
     *
     * 2. 可变参数本质
     *    可变参数本质上就是数组：
     *
     *    int... nums  <=>  int[] nums
     *
     *    所以在方法内部可以直接使用：
     *    nums.length
     *    nums[0]
     *    for (int num : nums) {}
     *
     * 3. 调用方式
     *    test();                  // 可以传 0 个参数
     *    test(1);                 // 传 1 个参数
     *    test(1, 2, 3);           // 传多个参数
     *
     *    int[] arr = {1, 2, 3};
     *    test(arr);               // 也可以直接传数组
     *
     * 4. 可变参数可以不传值
     *    test();
     *    此时 nums 是一个长度为 0 的数组，而不是 null。
     *
     * 5. 可以传 null
     *    test((int[]) null);
     *    此时 nums == null。
     *
     *    注意：
     *    test(null) 在存在多个重载方法时可能产生歧义。
     *
     * 6. 可变参数必须放在参数列表的最后
     *
     *    正确：
     *    public static void test(String name, int... nums) {}
     *    可变参数有多少吃多少会导致第二个 name无法正常录入
     *
     *    错误：
     *    public static void test(int... nums, String name) {}
     *
     * 7. 一个方法最多只能有一个可变参数
     *
     *    错误：
     *    public static void test(int... a, String... b) {}
     *
     * 8. 可变参数可以和普通参数一起使用
     *
     *    public static void test(String name, int... scores) {}
     *
     *    test("张三", 90, 80, 95);
     *
     *    name   = "张三"
     *    scores = {90, 80, 95}
     *
     * 9. 可变参数不能和数组进行重载
     *
     *    下面两个方法不能同时存在：
     *
     *    test(int[] nums)
     *    test(int... nums)
     *
     *    因为 int... 本质上就是 int[]。
     *
     * 10. 可变参数和普通参数重载
     *
     *    public static void test(int x) {}
     *    public static void test(int... x) {}
     *
     *    test(10);
     *
     *    优先调用 test(int x)，
     *    因为普通参数的匹配优先级高于可变参数。
     *
     * 11. main 方法也可以使用可变参数
     *
     *    public static void main(String... args) {}
     *
     *    等价于：
     *
     *    public static void main(String[] args) {}
     *
     * 12. 可变参数可以使用各种类型
     *
     *    String... names
     *    int... nums
     *    Object... objects
     *    T... values
     *
     * 13. 最重要的面试总结
     *
     *    可变参数 = 本质是数组
     *
     *    ① 可以传 0 个、1 个或多个参数
     *    ② 可以直接传数组
     *    ③ 一个方法最多只能有一个可变参数
     *    ④ 可变参数必须放在最后
     *    ⑤ int... 和 int[] 不能重载
     *    ⑥ 普通参数匹配优先于可变参数
     *
     * ==================== 一句话记忆 ====================
     *
     *    可变参数本质是数组，
     *    一个方法最多一个，
     *    而且必须放最后。
     *
     */
}
