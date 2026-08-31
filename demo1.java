package com.java40_Map.LinkHashMap;

import java.util.LinkedHashMap;
import java.util.LinkedHashSet;

public class demo1 {
    //LinkedHashMap顾名思义linked连接的代表有序
    //底层数据结构是依然哈希表，只是每个键值对元素又额外的多了一个双链表的机制记录存储的顺序。
    public static void main(String[] args) {
        LinkedHashMap<String,Integer> Map = new LinkedHashMap<>();
        Map.put("a",123);
        Map.put("b",323);
        Map.put("c",2343);
        Map.put("e",1223);
        Map.put("f",122);
        Map.forEach((o1,o2)-> System.out.println(o1 + " = " + o2));
        /*
         * ========================= LinkedHashMap =========================
         *
         * 1. 基本定义
         * -------------------------------------------------
         * LinkedHashMap 是 HashMap 的子类。
         *
         * 核心特点：
         *     HashMap + 双向链表
         *
         * 既拥有 HashMap 的快速查找能力，
         * 又可以维护 Map 中元素的顺序。
         *
         *
         * 2. 底层数据结构
         * -------------------------------------------------
         * LinkedHashMap 底层本质上仍然是 HashMap 的哈希表，
         * 在此基础上增加了一条双向链表。
         *
         * HashMap 负责：
         *     根据 key 快速定位数据
         *
         * 双向链表负责：
         *     维护元素之间的顺序
         *
         * 可以理解为：
         *
         *     哈希表：
         *         key -> hash -> bucket -> node
         *
         *     双向链表：
         *         A <-> B <-> C <-> D
         *
         *
         * 3. 为什么 LinkedHashMap 能保持顺序？
         * -------------------------------------------------
         * 因为每个节点除了 HashMap 中原有的数据外，
         * 还额外维护：
         *
         *     before
         *     after
         *
         * 用来保存前驱节点和后继节点。
         *
         * 所以遍历 LinkedHashMap 时，
         * 可以按照双向链表维护的顺序进行遍历。
         *
         *
         * 4. 默认顺序：插入顺序
         * -------------------------------------------------
         * 默认：
         *
         *     accessOrder = false
         *
         * 例如：
         *
         *     put(3, "C")
         *     put(1, "A")
         *     put(2, "B")
         *
         * 遍历结果：
         *
         *     3 -> 1 -> 2
         *
         * 即按照元素第一次插入的顺序遍历。
         *
         *
         * 5. accessOrder = true
         * -------------------------------------------------
         * LinkedHashMap 可以通过构造方法开启“访问顺序”：
         *
         *     new LinkedHashMap<>(16, 0.75f, true);
         *
         * 此时：
         *
         *     accessOrder = true
         *
         * 访问一个元素后，
         * 该元素会移动到双向链表的尾部。
         *
         * 例如：
         *
         *     原来：1 -> 2 -> 3
         *
         *     get(1)
         *
         *     变成：2 -> 3 -> 1
         *
         * 此时：
         *
         *     头部 = 最久没有访问的元素
         *     尾部 = 最近访问的元素
         *
         *
         * 6. LinkedHashMap 可以实现 LRU
         * -------------------------------------------------
         * LRU：
         *     Least Recently Used
         *     最近最少使用
         *
         * LinkedHashMap 实现 LRU 的经典组合：
         *
         *     accessOrder = true
         *     +
         *     removeEldestEntry()
         *
         * 当缓存超过容量时，
         * 删除链表头部的最老元素。
         *
         *
         * 7. removeEldestEntry()
         * -------------------------------------------------
         * LinkedHashMap 提供：
         *
         *     protected boolean removeEldestEntry(...)
         *
         * 可以重写该方法控制是否删除最老元素。
         *
         * 例如：
         *
         *     return size() > 3;
         *
         * 表示：
         *     容量超过 3 时，删除最老元素。
         *
         * 这也是 LinkedHashMap 实现简单 LRU Cache 的核心。
         *
         *
         * 8. get / put / remove
         * -------------------------------------------------
         * get：
         *     HashMap 中负责查找
         *
         *     如果 accessOrder = true，
         *     访问后还会调整双向链表顺序。
         *
         * put：
         *     既要维护 HashMap，
         *     又要维护双向链表。
         *
         * remove：
         *     不仅要从 HashMap 删除，
         *     还要从双向链表中摘除节点。
         *
         *
         * 9. 时间复杂度
         * -------------------------------------------------
         * 正常情况下：
         *
         *     get     O(1)
         *     put     O(1)
         *     remove  O(1)
         *
         * 因为：
         *     HashMap 平均查找 O(1)
         *     双向链表节点移动/删除 O(1)
         *
         *
         * 10. 是否线程安全
         * -------------------------------------------------
         * LinkedHashMap 本身不是线程安全的。
         *
         * 如果多个线程同时修改，
         * 需要额外的同步措施。
         *
         *
         * 11. null
         * -------------------------------------------------
         * LinkedHashMap：
         *
         *     允许一个 null key
         *     允许多个 null value
         *
         *
         * 12. LinkedHashMap vs HashMap
         * -------------------------------------------------
         *
         * HashMap：
         *     哈希表
         *     不保证遍历顺序
         *
         * LinkedHashMap：
         *     哈希表 + 双向链表
         *     默认维护插入顺序
         *
         *
         * 13. LinkedHashMap vs TreeMap
         * -------------------------------------------------
         *
         * LinkedHashMap：
         *     按插入顺序 / 访问顺序
         *
         * TreeMap：
         *     按 Key 的大小排序
         *
         * 注意：
         *     LinkedHashMap 的“有序”
         *     ≠ TreeMap 的“排序”
         *
         *
         * 14. 面试核心一句话
         * -------------------------------------------------
         * LinkedHashMap = HashMap + 双向链表
         *
         * 默认按照插入顺序遍历，
         * accessOrder=true 时按照访问顺序遍历，
         * 配合 removeEldestEntry() 可以实现 LRU。
         *
         * ================================================================
         */
    }
}
