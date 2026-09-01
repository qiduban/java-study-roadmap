package com.java42;
/*
 * ========================= Java Stream API 速查 =========================
 *
 * Stream 操作分为两大类：
 *
 * 1. 中间操作（Intermediate Operation）
 *    - 返回 Stream
 *    - 可以连续调用
 *    - 惰性执行：不会立即执行
 *    - 遇到终止操作后才真正执行
 *
 * 2. 终止操作（Terminal Operation）
 *    - 不再返回 Stream
 *    - 一个 Stream 只能有一个终止操作
 *    - 执行终止操作后，Stream 就不能再次使用
 *
 *
 * Stream 常见结构：
 *
 * 数据源
 *   ↓
 * stream()
 *   ↓
 * 中间操作
 *   ↓
 * 中间操作
 *   ↓
 * 中间操作
 *   ↓
 * 终止操作
 *   ↓
 * 得到结果
 *
 *
 * ======================================================================
 */


/*
 * ========================= 一、中间操作 =========================
 *
 * 特点：
 * ① 返回 Stream
 * ② 可以连续调用
 * ③ 惰性执行
 * ④ 不会立即产生最终结果
 *
 * ======================================================================
 */


/*
 * 1. filter()
 *
 * 作用：过滤元素
 *
 * 参数：Predicate<T>
 * 返回：Stream<T>
 *
 * 示例：
 *
 * list.stream()
 *     .filter(x -> x > 10)
 *     .toList();
 *
 * 含义：
 * 只保留满足条件的元素
 *
 * 例如：
 * [1, 5, 10, 20]
 *       ↓ filter(x -> x > 10)
 * [20]
 */


/*
 * 2. map()
 *
 * 作用：将元素转换成另外一种形式
 *
 * 参数：Function<T, R>
 * 返回：Stream<R>
 *
 * 示例：
 *
 * list.stream()
 *     .map(x -> x * 2)
 *     .toList();
 *
 * [1, 2, 3]
 *      ↓
 * [2, 4, 6]
 *
 * 核心：
 * 一个元素 → 一个元素
 */


/*
 * 3. mapToInt()
 *
 * 作用：将 Stream<T> 转换成 IntStream
 *
 * 示例：
 *
 * users.stream()
 *      .mapToInt(User::getAge)
 *      .sum();
 *
 * 常用于：
 * 求和、平均值、最大值、最小值等数字计算
 */


/*
 * 4. mapToLong()
 *
 * 作用：将 Stream<T> 转换成 LongStream
 *
 * 示例：
 *
 * users.stream()
 *      .mapToLong(User::getMoney)
 *      .sum();
 */


/*
 * 5. mapToDouble()
 *
 * 作用：将 Stream<T> 转换成 DoubleStream
 *
 * 示例：
 *
 * users.stream()
 *      .mapToDouble(User::getScore)
 *      .average();
 */


/*
 * 6. flatMap()
 *
 * 作用：将多个 Stream / 集合元素展开、打平
 *
 * 返回：Stream<R>
 *
 * 核心：
 * map     = 转换
 * flatMap = 转换 + 打平
 *
 * 例如：
 *
 * [[1,2], [3,4], [5,6]]
 *          ↓ flatMap
 * [1,2,3,4,5,6]
 *
 * 示例：
 *
 * list.stream()
 *     .flatMap(Collection::stream)
 *     .toList();
 *
 * 重点：
 * flatMap 是 Stream 面试中的高频知识点
 */


/*
 * 7. distinct()
 *
 * 作用：去重
 *
 * 返回：Stream<T>
 *
 * 示例：
 *
 * Stream.of(1, 2, 2, 3, 3)
 *       .distinct()
 *       .toList();
 *
 * 结果：
 * [1, 2, 3]
 *
 * 注意：
 * 对象去重依赖 equals() 和 hashCode()
 */


/*
 * 8. sorted()
 *
 * 作用：排序
 *
 * 返回：Stream<T>
 *
 * 默认升序：
 *
 * list.stream()
 *     .sorted()
 *     .toList();
 *
 * 自定义排序：
 *
 * users.stream()
 *      .sorted(Comparator.comparing(User::getAge))
 *      .toList();
 *
 * 降序：
 *
 * users.stream()
 *      .sorted(
 *          Comparator.comparing(User::getAge).reversed()
 *      )
 *      .toList();
 */


/*
 * 9. limit()
 *
 * 作用：只保留前 N 个元素
 *
 * 返回：Stream<T>
 *
 * 示例：
 *
 * list.stream()
 *     .limit(5)
 *     .toList();
 *
 * [1,2,3,4,5,6,7]
 *       ↓ limit(5)
 * [1,2,3,4,5]
 *
 * 特点：
 * 短路操作
 */


/*
 * 10. skip()
 *
 * 作用：跳过前 N 个元素
 *
 * 返回：Stream<T>
 *
 * 示例：
 *
 * list.stream()
 *     .skip(3)
 *     .toList();
 *
 * [1,2,3,4,5]
 *       ↓ skip(3)
 * [4,5]
 */


/*
 * 11. peek()
 *
 * 作用：查看 Stream 中间处理过程
 *
 * 返回：Stream<T>
 *
 * 主要用途：
 * 调试、查看中间结果
 *
 * 示例：
 *
 * list.stream()
 *     .filter(x -> x > 10)
 *     .peek(x -> System.out.println(x))
 *     .map(x -> x * 2)
 *     .toList();
 *
 * 注意：
 * 不建议使用 peek() 编写核心业务逻辑
 */


/*
 * 12. takeWhile()   【Java 9+】
 *
 * 作用：
 * 从头开始获取满足条件的元素，
 * 一旦遇到不满足条件的元素，就停止。
 *
 * 示例：
 *
 * Stream.of(1, 2, 3, 6, 4, 5)
 *       .takeWhile(x -> x < 5)
 *       .toList();
 *
 * 结果：
 * [1,2,3]
 *
 * 注意：
 * 是“遇到第一个不满足条件的元素就停止”
 */


/*
 * 13. dropWhile()   【Java 9+】
 *
 * 作用：
 * 从头开始丢弃满足条件的元素，
 * 一旦遇到不满足条件的元素，就停止丢弃。
 *
 * 示例：
 *
 * Stream.of(1, 2, 3, 6, 4, 5)
 *       .dropWhile(x -> x < 5)
 *       .toList();
 *
 * 结果：
 * [6,4,5]
 */


/*
 * ========================= 二、终止操作 =========================
 *
 * 特点：
 * ① 不返回 Stream
 * ② 会真正触发 Stream 执行
 * ③ 一个 Stream 只能执行一次终止操作
 *
 * ======================================================================
 */


/*
 * 1. forEach()
 *
 * 作用：遍历元素
 *
 * 返回：void
 *
 * 示例：
 *
 * list.stream()
 *     .forEach(System.out::println);
 *
 * 注意：
 * 不保证并行 Stream 中的执行顺序
 */


/*
 * 2. forEachOrdered()
 *
 * 作用：按照 Stream 的顺序遍历
 *
 * 返回：void
 *
 * 示例：
 *
 * list.parallelStream()
 *     .forEachOrdered(System.out::println);
 *
 * 与 forEach 的区别：
 *
 * forEach         → 不保证顺序
 * forEachOrdered  → 尽量保证 Stream 遇到顺序
 */


/*
 * 3. toList()   【Java 16+】
 *
 * 作用：将 Stream 转换成 List
 *
 * 返回：List<T>
 *
 * 示例：
 *
 * List<Integer> result = list.stream()
 *                            .filter(x -> x > 10)
 *                            .toList();
 *
 * 注意：
 * toList() 得到的 List 不保证可修改，
 * 通常不要对其执行 add/remove。
 */


/*
 * 4. collect()
 *
 * 作用：将 Stream 中的数据收集成指定结果
 *
 * 返回：R
 *
 * 最常用的终止操作之一
 *
 * 示例：
 *
 * List<Integer> list = stream.collect(Collectors.toList());
 *
 * Set<Integer> set = stream.collect(Collectors.toSet());
 *
 * Map<String, User> map = stream.collect(
 *     Collectors.toMap(
 *         User::getName,
 *         user -> user
 *     )
 * );
 *
 * 常配合 Collectors 使用
 */


/*
 * 5. count()
 *
 * 作用：统计元素数量
 *
 * 返回：long
 *
 * 示例：
 *
 * long count = list.stream()
 *                  .filter(x -> x > 10)
 *                  .count();
 */


/*
 * 6. min()
 *
 * 作用：获取最小值
 *
 * 返回：Optional<T>
 *
 * 示例：
 *
 * Optional<Integer> min = list.stream()
 *                             .min(Integer::compareTo);
 *
 * 为什么返回 Optional？
 * 因为 Stream 可能为空。
 */


/*
 * 7. max()
 *
 * 作用：获取最大值
 *
 * 返回：Optional<T>
 *
 * 示例：
 *
 * Optional<Integer> max = list.stream()
 *                             .max(Integer::compareTo);
 */


/*
 * 8. findFirst()
 *
 * 作用：获取第一个元素
 *
 * 返回：Optional<T>
 *
 * 示例：
 *
 * Optional<Integer> result = list.stream()
 *                                .filter(x -> x > 10)
 *                                .findFirst();
 *
 * 特点：
 * 短路操作
 */


/*
 * 9. findAny()
 *
 * 作用：获取任意一个满足条件的元素
 *
 * 返回：Optional<T>
 *
 * 示例：
 *
 * Optional<Integer> result = list.stream()
 *                                .filter(x -> x > 10)
 *                                .findAny();
 *
 * 特点：
 * 短路操作
 *
 * 在 parallelStream() 中，
 * findAny() 通常比 findFirst() 更适合并行处理。
 */


/*
 * 10. anyMatch()
 *
 * 作用：判断是否至少有一个元素满足条件
 *
 * 返回：boolean
 *
 * 示例：
 *
 * boolean result = list.stream()
 *                     .anyMatch(x -> x > 100);
 *
 * 含义：
 * 有没有一个元素 > 100？
 *
 * 特点：
 * 短路操作
 */


/*
 * 11. allMatch()
 *
 * 作用：判断是否所有元素都满足条件
 *
 * 返回：boolean
 *
 * 示例：
 *
 * boolean result = list.stream()
 *                     .allMatch(x -> x > 0);
 *
 * 含义：
 * 是不是所有元素都 > 0？
 *
 * 特点：
 * 短路操作
 */


/*
 * 12. noneMatch()
 *
 * 作用：判断是否没有元素满足条件
 *
 * 返回：boolean
 *
 * 示例：
 *
 * boolean result = list.stream()
 *                     .noneMatch(x -> x < 0);
 *
 * 含义：
 * 有没有元素 < 0？
 * → 没有
 *
 * 特点：
 * 短路操作
 */


/*
 * 13. reduce()
 *
 * 作用：将多个元素聚合成一个结果
 *
 * 常用于：
 * 求和、求乘积、最大值、字符串拼接等
 *
 * 示例：
 *
 * int sum = list.stream()
 *               .reduce(0, (a, b) -> a + b);
 *
 * 或：
 *
 * int sum = list.stream()
 *               .reduce(0, Integer::sum);
 *
 * [1,2,3,4]
 *    ↓ reduce
 * 10
 *
 * 核心：
 * 多个元素 → 一个结果
 */


/*
 * 14. toArray()
 *
 * 作用：将 Stream 转换成数组
 *
 * 返回：Object[] / 指定类型数组
 *
 * 示例：
 *
 * Object[] array = list.stream()
 *                      .toArray();
 *
 * 指定类型：
 *
 * Integer[] array = list.stream()
 *                       .toArray(Integer[]::new);
 */


/*
 * ========================= 三、Collectors 常用方法 =========================
 *
 * Collectors 通常配合 collect() 使用。
 *
 * ======================================================================
 */


/*
 * 1. Collectors.toList()
 *
 * Stream → List
 *
 * stream.collect(Collectors.toList());
 */


/*
 * 2. Collectors.toSet()
 *
 * Stream → Set
 *
 * stream.collect(Collectors.toSet());
 */


/*
 * 3. Collectors.toMap()
 *
 * Stream → Map
 *
 * 示例：
 *
 * Map<Long, User> map = users.stream()
 *     .collect(Collectors.toMap(
 *         User::getId,
 *         user -> user
 *     ));
 *
 * 注意：
 * 如果 key 重复，会抛出异常。
 *
 * 可以提供重复 key 的处理方式：
 *
 * Collectors.toMap(
 *     User::getId,
 *     user -> user,
 *     (oldValue, newValue) -> newValue
 * );
 */


/*
 * 4. Collectors.groupingBy()
 *
 * 作用：分组
 *
 * 类似 SQL：
 *
 * GROUP BY
 *
 * 示例：
 *
 * Map<String, List<User>> result =
 *     users.stream()
 *          .collect(
 *              Collectors.groupingBy(User::getDepartment)
 *          );
 *
 * department → List<User>
 */


/*
 * 5. groupingBy() + counting()
 *
 * 作用：分组统计数量
 *
 * 示例：
 *
 * Map<String, Long> result =
 *     users.stream()
 *          .collect(
 *              Collectors.groupingBy(
 *                  User::getDepartment,
 *                  Collectors.counting()
 *              )
 *          );
 */


/*
 * 6. groupingBy() + averagingInt()
 *
 * 作用：分组求平均值
 *
 * 示例：
 *
 * Map<String, Double> result =
 *     users.stream()
 *          .collect(
 *              Collectors.groupingBy(
 *                  User::getDepartment,
 *                  Collectors.averagingInt(User::getAge)
 *              )
 *          );
 */


/*
 * 7. partitioningBy()
 *
 * 作用：按照 true / false 分成两组
 *
 * 示例：
 *
 * Map<Boolean, List<User>> result =
 *     users.stream()
 *          .collect(
 *              Collectors.partitioningBy(
 *                  user -> user.getAge() >= 18
 *              )
 *          );
 *
 * 区别：
 *
 * groupingBy       → 多组
 * partitioningBy   → true / false 两组
 */


/*
 * 8. joining()
 *
 * 作用：将字符串拼接起来
 *
 * 示例：
 *
 * String result = names.stream()
 *                      .collect(Collectors.joining(","));
 *
 * 结果：
 * 张三,李四,王五
 *
 *
 * 也可以：
 *
 * Collectors.joining(",", "[", "]")
 *
 * 结果：
 * [张三,李四,王五]
 */


/*
 * ========================= 四、Stream 操作分类总结 =========================
 */


/*
 *
 * 【中间操作】
 *
 * filter()       → 过滤
 * map()          → 转换
 * mapToInt()     → 转 IntStream
 * mapToLong()    → 转 LongStream
 * mapToDouble()  → 转 DoubleStream
 * flatMap()      → 转换 + 打平
 * distinct()     → 去重
 * sorted()       → 排序
 * limit()        → 获取前 N 个
 * skip()         → 跳过前 N 个
 * peek()         → 查看中间结果
 * takeWhile()    → 获取开头满足条件的数据
 * dropWhile()    → 丢弃开头满足条件的数据
 *
 *
 * 【终止操作】
 *
 * forEach()          → 遍历
 * forEachOrdered()   → 按顺序遍历
 * toList()           → 转 List
 * collect()          → 收集
 * count()            → 统计数量
 * min()              → 最小值
 * max()              → 最大值
 * findFirst()        → 找第一个
 * findAny()          → 找任意一个
 * anyMatch()         → 任意一个满足
 * allMatch()         → 全部满足
 * noneMatch()        → 全部不满足
 * reduce()           → 聚合
 * toArray()          → 转数组
 *
 *
 * 【Collectors 常用】
 *
 * toList()            → 转 List
 * toSet()             → 转 Set
 * toMap()             → 转 Map
 * groupingBy()        → 分组
 * partitioningBy()    → true / false 分组
 * counting()          → 计数
 * averagingInt()      → 平均值
 * summingInt()        → 求和
 * joining()           → 字符串拼接
 *
 *
 * ======================================================================
 */


import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.stream.Stream;

/*
 * ========================= 五、面试重点记忆 =========================
 *
 * 中间操作：
 *
 * filter  → 筛选
 * map     → 转换
 * flatMap → 打平
 * sorted  → 排序
 * distinct → 去重
 * limit   → 截取
 * skip    → 跳过
 *
 *
 * 终止操作：
 *
 * collect    → 收集
 * forEach    → 遍历
 * count      → 计数
 * reduce     → 聚合
 * findFirst  → 找第一个
 * findAny    → 找任意
 * anyMatch   → 任意满足
 * allMatch   → 全部满足
 * noneMatch  → 全部不满足
 *
 *
 * 最重要的核心概念：
 *
 * 中间操作 = 返回 Stream + 惰性执行
 *
 * 终止操作 = 不返回 Stream + 触发执行
 *
 * 一个 Stream：
 *
 * 可以有多个中间操作
 * 只能有一个终止操作
 *
 *
 * ======================================================================
 */
public class stream_demo2 {
    public static void main(String[] args) {
//        单列集合 default Stream<E> stream() Collection中的默认方法
//        双列集合 无 无法直接使用stream流
//        数组 public static <T> Stream<T> stream(T[] array) Arrays工具类中的静态方法
//        一堆零散数据 public static<T> Stream<T> of(T... values) Stream接口中的静态方法
        //1.单链集合获取stream流
        ArrayList<String> list = new ArrayList<>();
        Collections.addAll(list,"a","b","s","v","fsd","asd","as","sadf");
        //获取一条流水线，并将集合中的数据放到流水线上
        Stream<String> stream = list.stream();
        //使用终结方法打印一下
        stream.filter(o1->o1.startsWith("a")).filter(o1->o1.length() > 2).forEach(o1-> System.out.println(o1));
        //双链集合
        //1.创建双链集合
        HashMap<String,Integer> hm = new HashMap<>();
//2.添加数据
        hm.put("aaa",111);
        hm.put("bbb",222);
        hm.put("ccc",333);
        hm.put("ddd",444);
//3.第一种获取stream流
        hm.keySet().stream().forEach(s -> System.out.println(s));
//4.第二种获取stream流
        hm.entrySet().stream().forEach(s-> System.out.println(s));
        int[]arr1={1,2,3,4,5,6,7,8,9,10};
        String[] arr2;
//2.获取stream流
// Arrays.stream(arr1).forEach(s-> System.out.println(s));
//System.out.println("=======
//Arrays.stream(arr2).forEach(s-> System.out.println(s));
//System.out.println("====
//注意:
//Stream接口中静态方法of的细节//方法的形参是一个可变参数，可以传递一堆零散的数据，也可以传递数组
//但是数组必须是引用数据类型的，如果传递基本数据类型，是会把整个数组当做一个元素，放到Stream当中。
        Stream.of(arr1).forEach(s-> System.out.println(s));//[I@41629346
    }
}
