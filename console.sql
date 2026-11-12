# ============================索引==================================
-- 索引结构：
-- 1. B+Tree索引：最常见的索引类型，大部分引擎都支持，InnoDB默认使用B+Tree索引。
-- 2. Hash索引：底层数据结构通过哈希表实现，只有精确匹配索引列的查询才有效，不支持范围查询。
-- 3. R-Tree（空间索引）：MyISAM引擎的一种特殊索引类型，主要用于地理空间数据类型，通常使用较少。
-- 4. Full-text（全文索引）：通过建立倒排索引，快速匹配文档内容，类似于Lucene、Solr、ES。
-- 不同存储引擎对索引的支持情况：
--                InnoDB       MyISAM       Memory
-- B+Tree索引       支持          支持           支持
-- Hash索引         不支持        不支持        支持
-- R-Tree索引       不支持        支持          不支持
-- Full-text索引    5.6版本后支持  支持          不支持

-- 索引的使用方法
# 创建索引
USE lyt;

-- 普通索引
CREATE INDEX ind_NAME ON customers (id);

SHOW INDEX FROM customers; -- 查看索引名

# 删除索引
DROP INDEX ind_NAME ON customers;

SHOW GLOBAL STATUS LIKE 'com%';

SELECT * FROM employee;
SHOW GLOBAL STATUS LIKE 'COM_______'; -- 查看数据库全局信息，知道该数据库的的主要任务是什么，来制定优化方案

SHOW VARIABLES LIKE 'slow_query_log'; -- 查看慢查询日志
SET GLOBAL slow_query_log  = ON;
SET GLOBAL long_query_time = 0.1;-- 设置慢查询时间
SHOW VARIABLES LIKE 'slow_query_log_file'; -- 查看慢查询日志文件的位置
SET GLOBAL log_output = 'FILE,TABLE'; -- 设置日志文件的类型
SHOW VARIABLES LIKE 'log_output'; -- 查看慢查询日志的输出方式

EXPLAIN
SELECT DISTINCT customers.name
FROM customers
JOIN lyt.orders o on customers.id = o.customerId;

SELECT *
FROM mysql.slow_log
ORDER BY start_time DESC;
TRUNCATE mysql.slow_log;

SET PROFILING  = 1; -- 开启profiling 查看SQL具体耗时时长
SELECT DISTINCT customers.name
FROM customers
         JOIN lyt.orders o on customers.id = o.customerId;
SHOW PROFILES;

-- explain查看查询性能
EXPLAIN
SELECT DISTINCT customers.name
FROM customers
         JOIN lyt.orders o on customers.id = o.customerId;
# MySQL 会返回一张执行计划表。
#
# 它可以帮助你了解：
# - 使用了哪张表。
# - 使用了哪个索引。
# - 预计扫描多少行。
# - 使用了哪种访问方式。
# - 是否使用临时表。
# - 是否需要额外排序。
#
# 2. EXPLAIN 重点字段
#     字段	       含义
# id	        查询块的标识
# select_type	查询类型
# table	        当前访问的表
# partitions	使用的分区
# type	        访问类型
# possible_keys	可能使用的索引
# key	        实际使用的索引
# key_len	    使用的索引长度
# ref	        索引与什么进行比较
# rows	        预计扫描行数
# filtered	    预计过滤比例
# Extra	        额外执行信息
#
# 其中最重要的是：
#
# type、possible_keys、key、rows、Extra。
EXPLAIN
SELECT d.dept_name '部门名称',
       m.name '领导名字',
       AVG(e.salary) '平均值'
FROM employee e
         JOIN lyt.department d on d.dept_id = e.dept_id
         JOIN employee m ON e.manager_id = m.id
GROUP BY d.dept_name, m.name
order by avg(salary) desc ;

# ============================ 子查询 + EXPLAIN 练习：employee ============================
# 查询目标：薪资 > 全公司平均、且 > 本部门平均；部门人数 >= 150；
#           同部门有人比他工资更高；年龄 < 本部门平均年龄。按薪资降序取前 10 名。
EXPLAIN
SELECT
    e.id,
    e.name,
    e.department,
    e.salary,
    d.avg_salary,
    (SELECT MAX(m.salary) FROM employee m WHERE m.dept_id = e.dept_id) AS dept_max_salary
FROM employee e
JOIN (SELECT dept_id, AVG(salary) AS avg_salary
        FROM employee
       GROUP BY dept_id) d
  ON d.dept_id = e.dept_id
WHERE e.salary > (SELECT AVG(salary) FROM employee)
  AND e.salary > d.avg_salary
  AND e.dept_id IN (SELECT s.dept_id FROM employee s
                     GROUP BY s.dept_id
                    HAVING COUNT(*) >= 150)
  AND EXISTS (SELECT 1 FROM employee sub
               WHERE sub.dept_id = e.dept_id
                 AND sub.salary > e.salary)
  AND e.age < (SELECT AVG(x.age) FROM employee x WHERE x.dept_id = e.dept_id)
ORDER BY e.salary DESC
LIMIT 10;

# ---------------------------- 看执行计划 ----------------------------
EXPLAIN
SELECT
    e.id,
    e.name,
    e.department,
    e.salary,
    d.avg_salary,
    (SELECT MAX(m.salary) FROM employee m WHERE m.dept_id = e.dept_id) AS dept_max_salary
FROM employee e
JOIN (SELECT dept_id, AVG(salary) AS avg_salary
        FROM employee
       GROUP BY dept_id) d
  ON d.dept_id = e.dept_id
WHERE e.salary > (SELECT AVG(salary) FROM employee)
  AND e.salary > d.avg_salary
  AND e.dept_id IN (SELECT s.dept_id FROM employee s
                     GROUP BY s.dept_id
                    HAVING COUNT(*) >= 150)
  AND EXISTS (SELECT 1 FROM employee sub
               WHERE sub.dept_id = e.dept_id
                 AND sub.salary > e.salary)
  AND e.age < (SELECT AVG(x.age) FROM employee x WHERE x.dept_id = e.dept_id)
ORDER BY e.salary DESC
LIMIT 10;

# 提示：EXPLAIN ANALYZE <上面的 SELECT> 能看到 actual time 和 loops（每个子查询实际执行了几次）
#       EXPLAIN 之后紧接 SHOW WARNINGS; 能看到优化器改写后的 SQL（/* select#N */ 对应 EXPLAIN 里的 id）