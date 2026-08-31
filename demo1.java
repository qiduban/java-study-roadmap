package com.java40_Map.TreeMap;

import java.util.TreeMap;

public class demo1 {
    public static void main(String[] args) {
        student a = new student("a", 3, 3);
        student b = new student("b", 1, 1);
        student c = new student("c", 5, 5);
        student d = new student("d", 4, 4);
        student e = new student("e", 2, 2);
        TreeMap<Integer , String> Tm = new TreeMap<>((o1,o2)->o2 - o1);
        Tm.put(a.ID,a.Name);
        Tm.put(b.ID,b.Name);
        Tm.put(c.ID,c.Name);
        Tm.put(d.ID,d.Name);
        Tm.put(e.ID,e.Name);
        System.out.println(Tm);
        /*
         * ============================ TreeMap ============================
         *
         * 1. 基本定义
         * -------------------------------------------------
         * TreeMap 是 Map 接口的一个实现，
         * 同时实现了 SortedMap、NavigableMap。
         *
         * 核心特点：
         *
         *     按照 Key 自动排序
         *
         * 注意：
         *     TreeMap 是按照 Key 排序，
         *     不是按照 Value 排序。
         *
         *
         * 2. 底层数据结构
         * -------------------------------------------------
         * TreeMap 底层使用红黑树。
         *
         * 红黑树是一种自平衡二叉搜索树。
         *
         * 因此 TreeMap 中的数据整体保持有序。
         *
         * 可以理解为：
         *
         *             20
         *            /  \
         *          10    30
         *         / \      \
         *        5  15      40
         *
         * 红黑树会通过旋转、重新着色等方式保持平衡。
         *
         *
         * 3. TreeMap 与 HashMap 的核心区别
         * -------------------------------------------------
         *
         * HashMap：
         *     通过 hash 定位元素
         *     平均 O(1)
         *     不保证顺序
         *
         * TreeMap：
         *     通过比较 Key 定位元素
         *     O(log n)
         *     按 Key 排序
         *
         *
         * 4. TreeMap 的排序依据
         * -------------------------------------------------
         * TreeMap 排序依赖：
         *
         *     Comparator
         *     或
         *     Comparable
         *
         *
         * 方式一：传入 Comparator
         *
         *     new TreeMap<>(Comparator.reverseOrder());
         *
         * 方式二：Key 实现 Comparable
         *
         *     class Student implements Comparable<Student>
         *
         *
         * 如果有 Comparator，
         * 则按照 Comparator 的规则比较 Key。
         *
         *
         * 5. 自定义排序是按照 Key 还是 Value？
         * -------------------------------------------------
         * TreeMap 自定义排序：
         *
         *     只能直接作用于 Key
         *
         * 例如：
         *
         *     TreeMap<Integer, String>
         *
         * Comparator 比较的是：
         *
         *     1、2、3、4...
         *
         * 而不是：
         *
         *     "A"、"B"、"C"...
         *
         * TreeMap 本身没有“按照 Value 排序”的模式。
         *
         *
         * 6. 如果想按照 Value 排序怎么办？
         * -------------------------------------------------
         * TreeMap 本身不负责 Value 排序。
         *
         * 一般做法：
         *
         *     先获取 entrySet()
         *     再把 Entry 放入 List
         *     最后根据 Value 使用 Comparator 排序
         *
         * 即：
         *
         *     TreeMap     -> Key 排序
         *
         *     List<Entry> -> 可以按 Value 排序
         *
         *
         * 7. TreeMap 的 Key 必须可比较
         * -------------------------------------------------
         * TreeMap 插入 Key 时，
         * 必须能够判断两个 Key 的大小关系。
         *
         * 可以通过：
         *
         *     Comparable
         *
         * 或：
         *
         *     Comparator
         *
         * 如果既不能比较，
         * 运行时可能出现：
         *
         *     ClassCastException
         *
         *
         * 8. TreeMap 的 Key 唯一性
         * -------------------------------------------------
         * HashMap 判断两个 Key 是否相同：
         *
         *     hashCode() + equals()
         *
         * TreeMap 判断两个 Key 是否“相同”：
         *
         *     compareTo() == 0
         *
         * 或：
         *
         *     Comparator.compare() == 0
         *
         * 也就是说：
         *
         *     TreeMap 的排序规则
         *     同时决定了 Key 的“唯一性”。
         *
         * 如果 compare(a, b) == 0，
         * TreeMap 会认为这两个 Key 在排序意义上相同，
         * 后面的 Value 可能覆盖前面的 Value。
         *
         *
         * 9. null
         * -------------------------------------------------
         * 默认情况下：
         *
         *     TreeMap 不支持 null key
         *
         * 因为 TreeMap 需要比较 Key，
         * null 通常无法正常参与比较。
         *
         * Value：
         *
         *     可以为 null
         *
         *
         * 10. 时间复杂度
         * -------------------------------------------------
         * 因为底层是红黑树：
         *
         *     get     O(log n)
         *     put     O(log n)
         *     remove  O(log n)
         *
         *
         * 11. TreeMap 最大优势：范围查询
         * -------------------------------------------------
         * TreeMap 不仅能排序，
         * 还可以快速进行范围操作。
         *
         * subMap(from, to)
         *     获取某个范围内的数据
         *
         * headMap(to)
         *     获取某个 Key 之前的数据
         *
         * tailMap(from)
         *     获取某个 Key 之后的数据
         *
         *
         * 12. subMap
         * -------------------------------------------------
         *
         *     map.subMap(20, 50)
         *
         * 默认表示：
         *
         *     20 <= key < 50
         *
         * 也可以：
         *
         *     map.subMap(20, true, 50, true)
         *
         * 表示：
         *
         *     20 <= key <= 50
         *
         *
         * 13. headMap
         * -------------------------------------------------
         *
         *     map.headMap(30)
         *
         * 表示：
         *
         *     key < 30
         *
         * 也可以：
         *
         *     map.headMap(30, true)
         *
         * 表示：
         *
         *     key <= 30
         *
         *
         * 14. tailMap
         * -------------------------------------------------
         *
         *     map.tailMap(30)
         *
         * 表示：
         *
         *     key >= 30
         *
         *
         * 15. 查找前驱/后继
         * -------------------------------------------------
         * TreeMap 提供：
         *
         *     lowerKey()
         *     floorKey()
         *     ceilingKey()
         *     higherKey()
         *
         * 非常重要。
         *
         * 假设已有：
         *
         *     10 20 30 40
         *
         * 查找 25：
         *
         *     lowerKey(25)
         *         -> 严格小于 25 的最大 Key
         *         -> 20
         *
         *     floorKey(25)
         *         -> 小于等于 25 的最大 Key
         *         -> 20
         *
         *     ceilingKey(25)
         *         -> 大于等于 25 的最小 Key
         *         -> 30
         *
         *     higherKey(25)
         *         -> 严格大于 25 的最小 Key
         *         -> 30
         *
         * 记忆：
         *
         *     lower    <
         *     floor    <=
         *     ceiling  >=
         *     higher   >
         *
         *
         * 16. Entry 版本
         * -------------------------------------------------
         * 除了：
         *
         *     lowerKey()
         *     floorKey()
         *     ceilingKey()
         *     higherKey()
         *
         * 还有：
         *
         *     lowerEntry()
         *     floorEntry()
         *     ceilingEntry()
         *     higherEntry()
         *
         * 区别：
         *
         *     xxxKey()
         *         -> 返回 Key
         *
         *     xxxEntry()
         *         -> 返回 Entry<Key, Value>
         *
         *
         * 17. 获取最小/最大 Key
         * -------------------------------------------------
         *
         *     firstKey()
         *         -> 最小 Key
         *
         *     lastKey()
         *         -> 最大 Key
         *
         * 还可以：
         *
         *     firstEntry()
         *     lastEntry()
         *
         *
         * 18. 降序遍历
         * -------------------------------------------------
         *
         *     descendingMap()
         *
         * 可以得到一个按照 Key 降序排列的 Map 视图。
         *
         *     descendingKeySet()
         *
         * 可以得到降序的 Key 集合。
         *
         *
         * 19. TreeMap vs HashMap
         * -------------------------------------------------
         *
         * HashMap：
         *     底层哈希表
         *     平均 O(1)
         *     不保证顺序
         *     适合快速查找
         *
         * TreeMap：
         *     底层红黑树
         *     O(log n)
         *     按 Key 排序
         *     适合有序数据、范围查询
         *
         *
         * 20. TreeMap vs LinkedHashMap
         * -------------------------------------------------
         *
         * LinkedHashMap：
         *     按插入顺序 / 访问顺序
         *
         * TreeMap：
         *     按 Key 的排序规则
         *
         * 记忆：
         *
         *     LinkedHashMap = 记住顺序
         *
         *     TreeMap = 维护排序
         *
         *
         * 21. 面试核心一句话
         * -------------------------------------------------
         * TreeMap = 红黑树 + Key 排序
         *
         * 排序规则来自 Comparator 或 Comparable。
         *
         * get / put / remove 都是 O(log n)。
         *
         * TreeMap 的核心优势不是“查找比 HashMap 快”，
         * 而是：
         *
         *     有序
         *     +
         *     范围查询
         *     +
         *     前驱/后继查询
         *
         * ================================================================
         */
    }
}
