ALTER TABLE lyt.employee ALTER COLUMN age SET DEFAULT 0;
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



# ============================================索引的优化===========================================
USE lyt;
SHOW CREATE TABLE employee;
-- 创建联合索引
CREATE INDEX ind_name_age_salary ON employee(name, age, salary);
SHOW INDEX FROM employee; -- 查看索引是否创建成功
EXPLAIN SELECT * FROM employee WHERE name ='王梦燊' and age = 19 and salary =120000;
# possible_keys   ind_name_age_salary

# key             ind_name_age_salary

# key_len         161
# 满足最左前缀法则而且并未跳过中间元素所以索引使用成功

EXPLAIN SELECT * FROM employee WHERE age = 19 and salary =120000; -- 跳过最左字段进行查找
# possible_keys   null

# key             null

# key_len         null
#因为左侧索引不存在 产生索引失效,查询时必须从最左边的字段开始匹配，才能使用连续的索引前缀。

EXPLAIN SELECT * FROM employee WHERE name ='王梦燊'; -- key_len = 152
EXPLAIN SELECT * FROM employee WHERE name ='王梦燊' and age = 19; -- key_len = 156
EXPLAIN SELECT * FROM employee WHERE name ='王梦燊' and salary = 120000; -- key_len =152
-- 查询时索引跳过中间区段导致后续索引失效。

# ============================================范围查询===========================================
USE lyt;
# 范围查询：> < >= <=、BETWEEN、IN、LIKE '前缀%'；命中索引时 type=range
SHOW INDEX FROM employee;

-- 1. 主键范围查询
SELECT id, name, salary FROM employee WHERE id BETWEEN 100 AND 120;
EXPLAIN SELECT * FROM employee WHERE id BETWEEN 100 AND 120;
# type=range  key=PRIMARY  rows=21
EXPLAIN SELECT * FROM employee WHERE id IN (1, 100, 1000);
# type=range  rows=3
EXPLAIN SELECT * FROM employee WHERE id > 1400;
# type=range  rows=100

-- 2. 联合索引：等值 + 范围
EXPLAIN SELECT * FROM employee WHERE name = '王梦燊' AND age > 19;
# type=range  key=ind_name_age_salary  key_len=156（用到了 name+age）
EXPLAIN SELECT * FROM employee WHERE name = '王梦燊' AND age > 19 AND salary = 120000;
# key_len 还是 156：age 是范围查询，后面的 salary 无法参与索引查找

-- 3. LIKE 前缀匹配也是范围查询
EXPLAIN SELECT * FROM employee WHERE name LIKE '王%';
# type=range  key_len=152（只用到 name）
EXPLAIN SELECT * FROM employee WHERE name LIKE '%燊';
# type=ALL，% 在前面索引失效

-- 4. 范围查询不满足最左前缀 → 索引失效
EXPLAIN SELECT * FROM employee WHERE salary BETWEEN 20000 AND 30000;
EXPLAIN SELECT * FROM employee WHERE age > 30;
# salary、age 都不是最左列 name，type=ALL 全表扫描

-- 5. 范围查询 + 覆盖索引：只查索引里有的列，不用回表
EXPLAIN SELECT id, age FROM employee WHERE name = '王梦燊' AND age > 19;
# Extra=Using index（覆盖索引）；SELECT * 则需要回表

# ============================================其他索引失效情况===========================================
USE lyt;

-- 1. 索引列上做函数或运算
EXPLAIN SELECT * FROM employee WHERE LEFT(name,1) = '王';
EXPLAIN SELECT * FROM employee WHERE id + 1 = 157;
EXPLAIN SELECT * FROM employee WHERE salary * 2 > 40000;
# 列被函数/运算包住，无法拿索引里的值直接比较 → type=ALL

-- 2. 隐式类型转换（字符串列不加引号）
EXPLAIN SELECT * FROM employee WHERE name = 156;
# possible_keys 有值但 key=NULL：varchar 和数字比较会把列转成数值 → 索引失效

-- 3. OR 连接的条件里有非索引列
EXPLAIN SELECT * FROM employee WHERE department = 'SA_REP' OR salary = 20000;
# salary 没索引 → 整个 OR 退化成全表扫 type=ALL
EXPLAIN SELECT * FROM employee WHERE id = 156 OR name = '王梦燊';
# 两边都有索引 → type=index_merge（还是走索引，但一般不如单条索引高效）

-- 4. 取反类条件：!=、NOT LIKE、NOT IN
EXPLAIN SELECT * FROM employee WHERE name != '王梦燊';
EXPLAIN SELECT * FROM employee WHERE name NOT LIKE '王%';
# 满足条件的行太多，优化器直接全表扫 → type=ALL

-- 5. IS NOT NULL（列几乎全非空时）
EXPLAIN SELECT * FROM employee WHERE dept_id IS NOT NULL;
# type=ALL（99.7% 的行都非空，不如全表扫）；换成 IS NULL 才走索引
EXPLAIN SELECT * FROM employee WHERE dept_id IS NULL;
# type=ref  key=idx_dept_id

# 前面已演示过：跳过最左列/中间列、范围查询后面的列、LIKE '%xx'、非最左列做范围
# 补充：区分度低的列查大部分数据时优化器也可能放弃索引，具体看数据分布（本例 department='SA_REP' 仍走 ref）

# ======================================================================================================================
# load指令优化大批量数据插入
USE lyt;

# local_infile：允许“客户端读本地文件”的开关，只有 LOAD DATA LOCAL INFILE 才需要；
# 服务器端 LOAD DATA INFILE 不受它影响，GLOBAL 表示全局生效（对新连接有效）
SET GLOBAL LOCAL_INFILE = 1; -- 打开load使用开关

USE lyt;

-- 1) 建一张同结构的空表（LIKE 不复制外键，导入更省事；别直接导进 employee，主键会冲突）
# CREATE TABLE ... LIKE：只复制表结构（列定义、索引），不复制数据，也不复制外键
# 重复练习时先执行：DROP TABLE IF EXISTS employee_load;
CREATE TABLE employee_load LIKE employee;-- 根据lyt.employee的结构出创建一张新表，但不复制表中的内容

-- 2) 导入
# 先用 SHOW VARIABLES LIKE 'secure_file_priv'; 确认服务器允许读文件的目录
LOAD DATA INFILE '/var/lib/mysql-files/employee.csv' -- INFILE：从服务器端读文件（路径必须在 secure_file_priv 目录下）
    INTO TABLE employee_load                         -- INTO TABLE：数据导入到哪张表
    CHARACTER SET utf8mb4                            -- CHARACTER SET：文件的字符集，防止中文乱码
    FIELDS TERMINATED BY ','                         -- FIELDS TERMINATED BY：字段之间的分隔符
    OPTIONALLY ENCLOSED BY '"'                       -- OPTIONALLY ENCLOSED BY：字段可选被双引号包住，包住才去掉
    LINES TERMINATED BY '\n'                         -- LINES TERMINATED BY：每行结尾符（Windows 文件改成 '\r\n'）
    IGNORE 1 LINES                                   -- IGNORE 1 LINES：跳过第 1 行（表头）
    (id, name, first_name, last_name, email, department, dept_id, manager_id,  -- 列清单：文件列 → 表列
     salary, commission, age, cretime);              -- 顺序要和 CSV 一致，空值 \N 会转成 NULL

# 对比：LOCAL 写法读客户端（Windows）文件，需要 local_infile=ON 且客户端启动加 --local-infile=1
# LOAD DATA LOCAL INFILE 'C:/dsh_workplace/employee.csv' INTO TABLE employee_load ...（后面参数相同）

-- 3) 检查
SHOW WARNINGS;                        -- SHOW WARNINGS：查看导入产生的警告，应为 0 条
SELECT COUNT(*) FROM employee_load;   -- 应为 1496

# 其他关键字：REPLACE / IGNORE —— 主键重复时替换 / 跳过（默认报错）
#             FIELDS ESCAPED BY —— 转义符，默认 '\'，\N 表示 NULL
SELECT * FROM employee WHERE id = 1;
DROP TABLE employee_load;

-- 导入测试
create table employee_demo like employee;
LOAD DATA INFILE '/var/lib/mysql-files/employee.csv'
INTO TABLE employee_demo
character set utf8mb4
FIELDS terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
IGNORE 1 LINES                                   -- IGNORE 1 LINES：跳过第 1 行（表头）
(id, name, first_name, last_name, email, department, dept_id, manager_id,  -- 列清单：文件列 → 表列，若表中的数据的顺序和.csv文件中的相同则可以省略
     salary, commission, age, cretime);
select * from employee_demo;
drop table employee_demo;
# ============================================================视图===========================================================
# 视图（View）是一种虚拟存在的表。
# 视图中的数据并不在数据库中实际存在，行和列数据来自定义视图的查询中使用的表，并且是在使用视图时动态生成的。
# 通俗的讲，视图只保存了查询的SQL逻辑，不保存查询结果。所以我们在创建视图的时候，主要的工作就落在创建这条SQL查询语句上。
CREATE OR REPLACE VIEW emp_v_1 AS SELECT id, name, salary from employee; -- 创建视图
SHOW CREATE VIEW emp_v_1; -- 查看视图创建语法
SELECT * FROM emp_v_1; -- 查看视图内容
CREATE OR REPLACE VIEW emp_v_1 AS SELECT id, name, salary from employee WHERE salary > 10000; -- 修改视图
ALTER VIEW emp_v_1 AS SELECT id, name, salary from employee WHERE salary > 10000;
SELECT * FROM emp_v_1; -- 查看视图内容
drop view emp_v_1; -- 删除视图

# ============================================视图的增删改查===========================================
USE lyt;

# 准备：建练习表（employee 的副本，避免改动 employee 真数据）
DROP VIEW IF EXISTS emp_v_crud, emp_v_stat, emp_v_rich;
DROP TABLE IF EXISTS emp_crud;
CREATE TABLE emp_crud LIKE employee; -- 复制 employee 的表结构（列、索引，不复制外键）
INSERT INTO emp_crud (id, name, first_name, last_name, email, department, dept_id, manager_id, salary, commission, age, cretime)
VALUES (9001, '测试一', '一', '测试', 't1@lyt.com', 'IT_PROG', 1, NULL, 8000.00, NULL, 25, NOW()),
       (9002, '测试二', '二', '测试', 't2@lyt.com', 'SA_REP', 3, NULL, 12000.00, 500.00, 30, NOW());

-- 简单视图：只是行列映射，可以增删改
CREATE OR REPLACE VIEW emp_v_crud AS
SELECT id, name, department, salary, age FROM emp_crud;

# 查：视图当普通表查
SELECT * FROM emp_v_crud;
SELECT * FROM emp_v_crud WHERE salary > 10000 ORDER BY salary DESC;

# 增：INSERT 视图 → 实际插入基表 emp_crud
INSERT INTO emp_v_crud (id, name, department, salary, age) VALUES (9003, '测试三', 'AD_VP', 15000, 40);
SELECT * FROM emp_crud WHERE id = 9003; -- 基表里也能查到

# 改：UPDATE 视图 → 实际修改基表
UPDATE emp_v_crud SET salary = salary + 1000 WHERE id = 9003;
SELECT * FROM emp_v_crud WHERE id = 9003;

# 删：DELETE 视图 → 实际删除基表行
DELETE FROM emp_v_crud WHERE id = 9003;
SELECT COUNT(*) FROM emp_v_crud; -- 删完剩 2 行

# 复杂视图（带聚合 / GROUP BY / DISTINCT / UNION 等）是只读的，下面 3 条会报错
# 注意：这 4 条“故意报错”的语句请单独选中执行，别整段跑
CREATE OR REPLACE VIEW emp_v_stat AS
SELECT department, AVG(salary) AS avg_salary, COUNT(*) AS cnt
FROM emp_crud GROUP BY department;
SELECT * FROM emp_v_stat;
INSERT INTO emp_v_stat (department, avg_salary, cnt) VALUES ('IT_PROG', 10000, 1); -- 报错 1471：视图不可插入
UPDATE emp_v_stat SET avg_salary = 1 WHERE department = 'IT_PROG';                 -- 报错 1288：视图不可更新
DELETE FROM emp_v_stat WHERE department = 'IT_PROG';                              -- 报错 1288：视图不可删除

# 视图里必须包含基表“非空且无默认值”的列，否则插入报错
INSERT INTO emp_v_crud (id, name, salary) VALUES (9004, '缺age', 8000); -- 报错 1423：底层表该列没有默认值

# WITH CHECK OPTION：通过视图写数据时必须满足视图的 WHERE 条件
CREATE OR REPLACE VIEW emp_v_rich AS
SELECT id, name, salary FROM emp_crud WHERE salary > 10000 WITH CHECK OPTION;
UPDATE emp_v_rich SET salary = 5000 WHERE id = 9002; -- 报错 1369：改完不满足 salary > 10000

# 收尾：练习完可删除
-- DROP VIEW IF EXISTS emp_v_crud, emp_v_stat, emp_v_rich;
-- DROP TABLE IF EXISTS emp_crud;

# with cascaded check potion相关知识点

CREATE OR REPLACE VIEW emp_v_2 AS SELECT emp_v_1.id, emp_v_1.name, emp_v_1.salary FROM emp_v_1 WITH CASCADED CHECK OPTION;
 -- 该关键字会要求插入的数据满足‘父视图’的限定条件（WHERE salary > 10000）
insert into emp_v_2 values (114514, '11', 11111); -- 不满足条件会报错
CREATE OR REPLACE VIEW emp_v_3 AS SELECT emp_v_2.id, emp_v_2.name, emp_v_2.salary FROM emp_v_2 where salary < 15000;
insert into emp_v_2 values (114, 111, 2000);-- 加上with casecaded check option 关键字后插入数据时会自动检查是否满足上一级视图的条件
DROP VIEW emp_v_1;
DROP VIEW emp_v_2;
DROP VIEW emp_v_3;
-- WITH CHECK OPTION：
-- 作用：限制通过视图 INSERT 或 UPDATE 的数据必须满足视图的 WHERE 条件。
-- 防止插入不符合条件的数据，也防止更新后数据不再符合条件。

-- WITH LOCAL CHECK OPTION：
-- 只对当前视图强制执行 CHECK OPTION 检查。
-- 递归检查底层视图，但底层视图没有 CHECK OPTION 时，不额外强制检查其 WHERE 条件。

-- WITH CASCADED CHECK OPTION：
-- 对当前视图以及所有底层视图递归执行检查。
-- 即使底层视图没有声明 CHECK OPTION，也会将其 WHERE 条件纳入检查。

-- 注意：
-- 1. 默认情况下，不写 LOCAL 或 CASCADED，相当于 CASCADED。
-- 2. 只适用于可更新视图。
-- 3. 不会修改视图原本的定义，只影响通过视图进行 INSERT 和 UPDATE 时的检查。
# ===================================================存储过程===========================================================
    -- 创建存储过程
CREATE PROCEDURE fun()
BEGIN
    SELECT dept_id,
        COUNT(*) FROM employee WHERE name = 'Barbara Moore'
    GROUP BY dept_id;
end;

-- 调用存储
call fun();

-- 查看存储
SHOW CREATE PROCEDURE fun;
SELECT * FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = 'employee';

-- 删除存储
DROP PROCEDURE fun;

# ------------------------------------------------变量----------------------------------------------------
 -- ‘@@’用在全局变量中
 -- ‘@’用在自定义变量中
-- MySQL变量：

-- 1. 系统变量（@@）
-- 由MySQL系统提供，用于控制和查看数据库运行配置。
-- GLOBAL：全局变量，影响整个MySQL服务。
-- SESSION：会话变量，只影响当前数据库连接。
-- 示例：SELECT @@GLOBAL.autocommit;

-- 2. 用户自定义变量（@）
-- 由用户自行创建和赋值，不需要提前声明。
-- 只在当前数据库连接中有效，连接关闭后自动释放。
-- 可以在多条SQL语句中重复使用。
-- 示例：SET @num = 100;
--      SELECT @num;

-- 3. 局部变量
-- 使用DECLARE声明，只能在存储程序内部使用。
-- 示例：DECLARE num INT DEFAULT 100;

-- 记忆：
-- @@：MySQL系统变量
-- @：用户自定义变量
-- 无@：存储程序中的局部变量

-- 查看系统变量
show global variables ;
select @@autocommit; -- 查看系统变量的状态，接下来可以用set设置系统变量的状态
set global autocommit = 1; -- 设置全局级别的变量 = SET @@autocommmit = 1;
set session autocommit  = 1; -- 设置会话级别的变量 = set @autocommit = 1;
-- 查看会话变量
SHOW SESSION VARIABLES ;
-- 用户自定义变量的赋值
SET @name_my = '王梦燊';
SET @name_mywife := '卢玥曈'; -- 这种方式同样也可以

-- 用户自定义变量的使用
SELECT @name_my, @name_mywife;

INSERT INTO employee (id, name, salary, age)
VALUES (11111, @name_mywife, 8888.00, 28);

select name from employee where name = '卢玥曈';

# SET @num := 100;                  -- 常量表达式
# SET @total := 100 + 200;          -- 数学表达式
# SET @b := @num;                   -- 变量表达式
# SET @name := CONCAT('张', '三');  -- 函数表达式
# SET @level := IF(@num > 50, 'A', 'B'); -- 条件表达式

# ======================局部变量===============================
CREATE PROCEDURE FUN2()
BEGIN
    DECLARE emp_count INT DEFAULT 0; -- 创建局部变量
    SET emp_count := 100;
    SELECT COUNT(*) INTO emp_count FROM employee; -- 查询总人数并将结果记录到emp_count中
    SELECT emp_count;
end;
CALL FUN2(); -- 调用局部变量
DROP PROCEDURE FUN2; -- 删除局部变量
# 局部变量只能在声明它的 BEGIN ... END 程序块中使用，以及该程序块内部嵌套的程序块中使用。程序块执行结束后，变量就超出了作用范围。



















