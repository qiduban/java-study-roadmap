package com.java41;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;

public class collections {
    /*
     * ==================== Java Collections ====================
     *
     * 一、Collections 是什么？
     *
     * Collections 是 java.util 包下的集合工具类。
     *
     * 主要作用：
     * 1. 对集合进行排序
     * 2. 查找集合中的最大值、最小值
     * 3. 对集合进行反转
     * 4. 对集合进行随机打乱
     * 5. 对集合进行复制、替换、填充
     * 6. 返回线程安全的集合
     * 7. 返回不可修改的集合
     *
     * 注意：
     *
     * Collection  ：接口，表示集合体系
     * Collections ：工具类，提供操作集合的方法
     *
     *
     * 二、常用方法
     *
     * 1. sort() —— 排序
     *
     *    List<Integer> list = new ArrayList<>();
     *    list.add(3);
     *    list.add(1);
     *    list.add(2);
     *
     *    Collections.sort(list);
     *
     *    结果：
     *    [1, 2, 3]
     *
     *    默认按照自然顺序升序排列。
     *
     *
     * 2. reverse() —— 反转集合
     *
     *    Collections.reverse(list);
     *
     *    [1, 2, 3]
     *        ↓
     *    [3, 2, 1]
     *
     *
     * 3. shuffle() —— 随机打乱
     *
     *    Collections.shuffle(list);
     *
     *    每次执行后，元素顺序可能不同。
     *
     *
     * 4. max() —— 获取最大值
     *
     *    int max = Collections.max(list);
     *
     *
     * 5. min() —— 获取最小值
     *
     *    int min = Collections.min(list);
     *
     *
     * 6. swap() —— 交换两个位置的元素
     *
     *    Collections.swap(list, 0, 1);
     *
     *    交换下标 0 和下标 1 的元素。
     *
     *
     * 7. fill() —— 用指定元素填充整个集合
     *
     *    Collections.fill(list, 0);
     *
     *    例如：
     *    [1, 2, 3]
     *        ↓
     *    [0, 0, 0]
     *
     *
     * 8. replaceAll() —— 替换指定元素
     *
     *    Collections.replaceAll(list, 1, 100);
     *
     *    将集合中所有的 1 替换成 100。
     *
     *
     * 9. frequency() —— 统计元素出现次数
     *
     *    int count = Collections.frequency(list, 10);
     *
     *    表示统计 10 在 list 中出现了多少次。
     *
     *
     * 10. binarySearch() —— 二分查找
     *
     *    int index = Collections.binarySearch(list, 10);
     *
     *    注意：
     *    使用 binarySearch() 前，
     *    集合通常需要先按照升序排列。
     *
     *    找到：
     *    返回元素下标
     *
     *    找不到：
     *    返回一个负数
     *
     *
     * 11. copy() —— 复制集合
     *
     *    Collections.copy(dest, src);
     *
     *    将 src 中的元素复制到 dest。
     *
     *    注意：
     *    dest 的 size 必须 >= src 的 size。
     *
     *    不是自动扩容。
     *
     *
     * 12. nCopies() —— 创建包含 n 个相同元素的 List
     *
     *    List<String> list =
     *        Collections.nCopies(3, "Java");
     *
     *    结果：
     *    [Java, Java, Java]
     *
     *    注意：
     *    返回的集合不能进行修改操作。
     *
     *
     * 三、排序相关
     *
     * 1. 默认升序
     *
     *    Collections.sort(list);
     *
     *
     * 2. 降序排序
     *
     *    Collections.sort(list, Collections.reverseOrder());
     *
     *
     *    例如：
     *
     *    [1, 3, 2]
     *        ↓
     *    [3, 2, 1]
     *
     *
     * 3. 使用 Comparator 自定义排序
     *
     *    Collections.sort(list, (a, b) -> b - a);
     *
     *    表示降序排列。
     *
     *
     * 四、线程安全相关
     *
     * Collections 可以将普通集合包装成线程安全集合。
     *
     * 1. synchronizedList()
     *
     *    List<Integer> list =
     *        Collections.synchronizedList(
     *            new ArrayList<>()
     *        );
     *
     *
     * 2. synchronizedSet()
     *
     *    Set<Integer> set =
     *        Collections.synchronizedSet(
     *            new HashSet<>()
     *        );
     *
     *
     * 3. synchronizedMap()
     *
     *    Map<Integer, String> map =
     *        Collections.synchronizedMap(
     *            new HashMap<>()
     *        );
     *
     *
     * 注意：
     * synchronizedXXX() 是通过包装的方式提供线程安全。
     *
     *
     * 五、不可修改集合
     *
     * Collections 可以创建不可修改的集合。
     *
     * 1. unmodifiableList()
     *
     *    List<Integer> list =
     *        Collections.unmodifiableList(
     *            originalList
     *        );
     *
     *    对返回的 list 进行：
     *
     *    add()
     *    remove()
     *    set()
     *
     *    等修改操作，会抛出：
     *
     *    UnsupportedOperationException
     *
     *
     * 2. unmodifiableSet()
     *
     *    Collections.unmodifiableSet(set);
     *
     *
     * 3. unmodifiableMap()
     *
     *    Collections.unmodifiableMap(map);
     *
     *
     * 六、Collections 与 Collection 的区别
     *
     *    Collection：
     *    └── 接口
     *        ├── List
     *        ├── Set
     *        └── Queue
     *
     *
     *    Collections：
     *    └── 工具类
     *        ├── sort()
     *        ├── reverse()
     *        ├── shuffle()
     *        ├── max()
     *        ├── min()
     *        ├── binarySearch()
     *        ├── frequency()
     *        ├── fill()
     *        ├── swap()
     *        ├── copy()
     *        ├── synchronizedXXX()
     *        └── unmodifiableXXX()
     *
     *
     * 七、Collections 与 Arrays 的区别
     *
     *    Collections：
     *    主要操作 Collection 类型的集合，
     *    例如 List、Set 等。
     *
     *    Arrays：
     *    主要操作数组。
     *
     *    例如：
     *
     *    Collections.sort(list);
     *
     *    Arrays.sort(array);
     *
     *
     * 八、常见面试考点
     *
     *    ① Collections 是工具类，不是接口。
     *
     *    ② Collections 中的方法大多数是 static 静态方法。
     *
     *    ③ Collections.sort() 默认升序排序。
     *
     *    ④ Collections.reverse() 是反转，不是排序。
     *
     *    ⑤ Collections.shuffle() 是随机打乱。
     *
     *    ⑥ Collections.max() 获取最大值。
     *
     *    ⑦ Collections.min() 获取最小值。
     *
     *    ⑧ Collections.binarySearch() 二分查找，
     *       使用前要保证集合有序。
     *
     *    ⑨ Collections.copy() 要求目标集合
     *       size >= 源集合 size。
     *
     *    ⑩ synchronizedXXX() 可以将普通集合包装成
     *       线程安全集合。
     *
     *    ⑪ unmodifiableXXX() 返回不可修改视图。
     *
     *
     * ==================== 一句话记忆 ====================
     *
     * Collection  = 集合接口
     *
     * Collections = 集合工具类
     *
     * Arrays      = 数组工具类
     *
     * Collections 最常用：
     *
     * sort      排序
     * reverse   反转
     * shuffle   打乱
     * max       最大值
     * min       最小值
     * swap      交换
     * fill      填充
     * frequency 统计次数
     * binarySearch 二分查找
     * copy      复制
     *
     * ==========================================================
     */
    public static void main(String[] args) {
        ArrayList<String> stu = new ArrayList<>();
        Collections.addAll(stu,"11","22","33");
        Random r = new Random();
        int index = r.nextInt(stu.size());
        System.out.println(stu.get(index));
        Collections.shuffle(stu);
        System.out.println(stu.get(0));
    }


}
