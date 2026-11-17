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

# --------------- if else 条件判断------------------
CREATE PROCEDURE FUN3(in score int, out result varchar(255))
BEGIN
-- DECLARE score int default 0;
-- DECLARE result varchar(255) default '-1';-- 设置局部变量并规定初始值
    if score >=  85 then
        set result := '优秀';
        elseif score > 70 and score <= 85 then
            set result := '良好';
            elseif score >= 60 and score <= 70 then
                set result = '及格';
                elseif score < 60 then
                    set result = '不及格';
    end if;
    select result;
end;
call fun3(98, @result);-- 调用过程时需要自定义一个变量来接收out的结果
drop procedure fun3;

-- MySQL存储过程参数类型：
-- 主要分为IN、OUT、INOUT三种，用于控制数据传递方向。

-- 1. IN（输入参数）
-- 调用存储过程时传入数据。
-- 存储过程可以读取、计算和修改参数。
-- 内部修改不会返回给调用者。
-- 默认参数类型就是IN。
-- 示例：CREATE PROCEDURE p1(IN num INT)

-- 2. OUT（输出参数）
-- 用于将存储过程内部处理的结果返回给调用者。
-- 进入存储过程时，参数初始值为NULL。
-- 通常使用SET或SELECT...INTO给参数赋值。
-- 调用时使用用户自定义变量接收返回结果。
-- 示例：CALL p1(@result);

-- 3. INOUT（输入输出参数）
-- 调用时需要传入初始值。
-- 存储过程可以读取并修改参数。
-- 修改后的结果会返回给调用者。
-- 调用前需要初始化用户自定义变量。
-- 示例：SET @num = 100;
--      CALL p1(@num);

-- 4. 注意事项
-- 参数在CREATE PROCEDURE的参数列表中声明。
-- 局部变量使用DECLARE在BEGIN...END开头声明。
-- 参数和局部变量在存储过程内部使用时不需要加@。
-- 普通SQL调用存储过程时，OUT和INOUT使用用户变量接收结果。
-- 存储函数的参数只能是IN。

-- 记忆：
-- IN：只进不出。
-- OUT：只出不进。
-- INOUT：既进又出。

# ============================================CASE 表达式===========================================
USE lyt;

# CASE 是“表达式”，不是语句：它返回一个值，所以能放在 SELECT、WHERE、GROUP BY、HAVING、ORDER BY、UPDATE SET 里。
# 两种写法：
# 1. 简单 CASE：CASE 列 WHEN 值 THEN 结果 ... ELSE 默认 END —— 只能做等值匹配（相当于 switch）
# 2. 搜索 CASE：CASE WHEN 条件 THEN 结果 ... ELSE 默认 END —— 能做范围、多条件判断（相当于 if / elseif，用得最多）
#
# 三条必须记住的规则：
# - 从上往下匹配，命中第一个就停，后面的分支不再判断 → 条件的顺序直接决定结果
# - 没有 ELSE 且全部条件不满足时，整个 CASE 返回 NULL（不是 0，也不是空字符串）
# - 所有 THEN/ELSE 的返回类型最好一致（数字和字符串混着写会被隐式转换）

-- 1. 简单 CASE：拿列的值去逐个等值匹配
SELECT id, name, department,
       CASE department
           WHEN 'IT_PROG' THEN '研发'
           WHEN 'SA_REP'  THEN '销售'
           WHEN 'AD_VP'   THEN '行政'
           ELSE '其他部门'
       END AS dept_cn
FROM employee
LIMIT 10;
# 简单 CASE 只能写 WHEN 值，写不了 WHEN department LIKE '%REP' 这种条件
# 坑：CASE department WHEN NULL THEN ... 永远不成立，因为 department = NULL 结果是 UNKNOWN，判 NULL 要用搜索 CASE + IS NULL

-- 2. 搜索 CASE：按范围 / 多条件判断（最常用）
SELECT id, name, salary,
       CASE
           WHEN salary IS NULL  THEN '无薪资'
           WHEN salary >= 20000 THEN '高薪'
           WHEN salary >= 12000 THEN '中高'
           WHEN salary >= 8000  THEN '中等'
           ELSE '偏低'
       END AS salary_level
FROM employee
WHERE id <= 20
ORDER BY salary DESC;
# 区间要从大到小写：如果把 WHEN salary >= 8000 放在最前面，20000 的也会被它先命中，全变成“中等”

-- 3. 没有 ELSE → 不满足条件返回 NULL，用 IFNULL / COALESCE 兜底
SELECT name, commission,
       CASE WHEN commission IS NOT NULL THEN commission END AS comm_raw,              -- 没有 ELSE，NULL 原样返回
       IFNULL(CASE WHEN commission IS NOT NULL THEN commission END, 0) AS comm_safe  -- 用 IFNULL 把 NULL 变成 0
FROM employee
WHERE id <= 10;
# NULL 参与 + - * / 和 SUM/AVG 都会把结果带成 NULL，所以聚合里一定要兜住

-- 4. 用在 ORDER BY：自定义排序（不按字母序、不按数字序，按我指定的权重）
SELECT id, name, department
FROM employee
ORDER BY CASE department
             WHEN 'AD_VP'   THEN 1
             WHEN 'IT_PROG' THEN 2
             WHEN 'SA_REP'  THEN 3
             ELSE 4
         END,
         id
LIMIT 20;
# 后面再跟一个 id 是为了同一权重内部顺序稳定（否则同组内顺序不确定）

-- 5. 和聚合函数配合做“行转列/条件统计”（面试常考）
SELECT department,
       COUNT(*)                                                          AS `总人数`,
       SUM(CASE WHEN salary >= 20000 THEN 1 ELSE 0 END)                   AS `高薪人数`,
       SUM(CASE WHEN salary >= 8000 AND salary < 20000 THEN 1 ELSE 0 END) AS `中等人数`,
       SUM(CASE WHEN salary < 8000 OR salary IS NULL THEN 1 ELSE 0 END)   AS `低薪人数`
FROM employee
GROUP BY department;
# SUM(CASE WHEN 条件 THEN 1 ELSE 0 END) 等价于 COUNT(CASE WHEN 条件 THEN 1 END)
# 这里不能用 COUNT(*)：COUNT(*) 数的是行数，不会按条件过滤

-- 6. 用在 WHERE：语法上允许，但 CASE 包住索引列 = 在列上做运算 → 索引直接失效
EXPLAIN SELECT * FROM employee WHERE CASE WHEN id > 0 THEN id END = 156;
# type=ALL：id 被 CASE 裹住，PRIMARY 用不上
EXPLAIN SELECT * FROM employee WHERE id = 156;
# type=const  key=PRIMARY

-- 7. 用在 UPDATE：一条 SQL 按条件批量改不同的值（比跑好几条 UPDATE 省事）
DROP TABLE IF EXISTS emp_case_demo;
CREATE TABLE emp_case_demo LIKE employee; -- 复制 employee 的结构，不动真数据
INSERT INTO emp_case_demo (id, name, department, salary, age)
VALUES (1, '甲', 'IT_PROG', 25000.00, 30),
       (2, '乙', 'SA_REP', 12000.00, 26),
       (3, '丙', 'AD_VP',   6000.00, 22);

UPDATE emp_case_demo
SET salary = CASE
                 WHEN salary >= 20000 THEN salary * 1.05  -- 高薪涨 5%
                 WHEN salary >= 10000 THEN salary * 1.10  -- 中薪涨 10%
                 ELSE salary * 1.20                       -- 低薪涨 20%
             END;
SELECT id, name, salary FROM emp_case_demo;

-- 8. 用在 GROUP BY：按自定义区间分组统计
SELECT CASE
           WHEN age < 25 THEN '25岁以下'
           WHEN age < 35 THEN '25-34'
           WHEN age < 45 THEN '35-44'
           ELSE '45岁以上'
       END                     AS age_group,
       COUNT(*)                AS cnt,
       ROUND(AVG(salary), 2)   AS avg_salary
FROM employee
GROUP BY age_group
ORDER BY age_group;
# MySQL 允许 GROUP BY 直接用 SELECT 里的别名；写法虽然方便，但如果分组字段上有索引，这种“先算再分组”的写法就用不上它了（本例没建 age 单列索引）

-- 收尾：练习完把临时表删掉
DROP TABLE IF EXISTS emp_case_demo;

-- CASE 踩坑清单：
-- 1. 命中即停：条件的顺序 = 结果，范围条件一定从大到小（或从小到大 + 反向），别乱序。
-- 2. 不写 ELSE 返回 NULL：后面接运算或聚合一定用 IFNULL / COALESCE 兜底。
-- 3. 类型要统一：THEN 1 和 THEN '1' 混着写会被隐式转成同一类型，比较结果可能不是你想要的。
-- 4. 别在 WHERE 里用 CASE 包住索引列：等价于在列上做函数运算 → type=ALL 全表扫描。
-- 5. CASE 是表达式不是语句：不能单独写 `CASE ... END;` 当 if 用；存储过程里做流程控制要用 IF ... THEN ... ELSEIF ... END IF。
-- 6. 判 NULL 别用简单 CASE：CASE col WHEN NULL 永远不匹配，要写 CASE WHEN col IS NULL THEN ...

-- ============================================递归循环===================================================
-- 设置当前会话允许存储过程递归的最大深度为 10
SET SESSION max_sp_recursion_depth = 10;
CREATE PROCEDURE FUN4(IN num INT, OUT r INT)
BEGIN
    IF num <= 0 THEN
        set r = 1;
    else
        call fun4(num - 1,r);
        set r = r * num;
        end if;

    end;
call FUN4(5,@r);
select @r;
drop procedure fun4;

-- ============================================while循环==========================================
create procedure FUN5(in n int, out r int)
begin
    declare total int default 0;
    while n > 0 do
        set total = total + n;
        set n = n -1;
        end while;
    select total;
end;
call FUN5(10,@R);

-- repeat（类似do.....while）
create procedure FUN6(in n int, out r int)
begin
    declare total int default 0;
    repeat
        set total = total + n;
        set n = n - 1;
    until n = 0
        end repeat;
    select total;
end;
call FUN6(10,@R);
-- loop循环

# ============================================LOOP 循环===========================================
USE lyt;

# LOOP 语法结构：
# [循环标签:] LOOP
#     循环体;
#     LEAVE 标签;      -- 跳出循环，相当于 break，不带它就是个死循环
#     ITERATE 标签;    -- 跳过本轮剩下的语句，回到循环开头，相当于 continue
# END LOOP [循环标签];
#
# 三条必须记住的规则：
# 1. LOOP 自己不判断条件，是死循环，退出全靠 LEAVE → 想让循环停下，LEAVE 是必需品。
# 2. 标签（label）必须跟着写：MySQL 没有 break / continue 这两个关键字，
#    只能写 LEAVE 标签名 / ITERATE 标签名，光写 LEAVE; 会直接语法报错。
# 3. LOOP 只能写在存储过程、函数、触发器、事件里；在普通 SQL 脚本里单独写一个 LOOP 会报语法错误。
#
# LEAVE 和 ITERATE 的区别：
#   LEAVE   往外跳：离开指定标签所在的循环（或 BEGIN...END 代码块），后面的循环不再执行。
#   ITERATE 往回跳：结束本轮，从标签所在循环的下一轮继续，循环没结束。
#   两个的作用域不同：ITERATE 只能用于循环（LOOP / WHILE / REPEAT）；
#   LEAVE 除了循环，还能用于带标签的 BEGIN...END 代码块。

-- 1. 基础用法：LOOP + LEAVE 求 1 到 n 的和
DROP PROCEDURE IF EXISTS p_loop_sum;
CREATE PROCEDURE p_loop_sum(IN n INT, OUT total INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    SET total := 0;
    my_loop: LOOP                          -- my_loop：循环标签，后面 LEAVE 要用到它
        IF i > n THEN
            LEAVE my_loop;                 -- LEAVE：条件一到就跳出整个循环，没有它这里会无限循环
        END IF;
        SET total := total + i;
        SET i := i + 1;                    -- 计数器自增必须写在循环体里，漏了同样会死循环
    END LOOP my_loop;                      -- 结束标签可写可不写，写就必须和开始标签同名
END;

CALL p_loop_sum(100, @total);
SELECT @total;                             -- 5050

-- 2. ITERATE：跳过本轮剩余语句，直接进入下一轮（求 1 到 n 里的偶数之和）
DROP PROCEDURE IF EXISTS p_loop_iterate;
CREATE PROCEDURE p_loop_iterate(IN n INT, OUT total INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    SET total := 0;
    even_loop: LOOP
        SET i := i + 1;                    -- 先自增，再做判断：ITERATE 会跳过后面的语句，自增写在后边就死循环了
        IF i > n THEN
            LEAVE even_loop;
        END IF;
        IF MOD(i, 2) = 1 THEN
            ITERATE even_loop;             -- 奇数：跳过下面的累加，直接回循环开头算下一个 i
        END IF;
        SET total := total + i;            -- 只有偶数能走到这一行
    END LOOP even_loop;
END;

CALL p_loop_iterate(10, @total);
SELECT @total;                             -- 2+4+6+8+10 = 30

# ITERATE 最容易踩的坑：它跳过的就是循环体里它后面所有语句，
# 所以“计数器自增”和“退出条件判断”一定要放在 ITERATE 之前，否则循环变量永远不变 → 死循环。

-- 3. 嵌套循环：内层 LEAVE 外层标签，一口气跳出两层
DROP PROCEDURE IF EXISTS p_loop_nested;
CREATE PROCEDURE p_loop_nested()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE j INT DEFAULT 1;
    DROP TEMPORARY TABLE IF EXISTS tmp_loop;                       -- 临时表只在当前连接可见，断开自动消失
    CREATE TEMPORARY TABLE tmp_loop (i INT, j INT);
    outer_loop: LOOP                                               -- 外层标签
        SET j := 1;
        inner_loop: LOOP                                           -- 内层标签
            IF j > 3 THEN
                LEAVE inner_loop;                                  -- 只跳出内层，外层继续
            END IF;
            INSERT INTO tmp_loop VALUES (i, j);                    -- 每轮的结果先攒进临时表，避免循环里刷一堆结果集
            IF i = 2 AND j = 2 THEN
                LEAVE outer_loop;                                  -- 标签写外层：直接连外层一起跳出
            END IF;
            SET j := j + 1;
        END LOOP inner_loop;
        SET i := i + 1;
        IF i > 3 THEN
            LEAVE outer_loop;
        END IF;
    END LOOP outer_loop;
    SELECT * FROM tmp_loop;                                        -- 最后统一输出：i=1 走完 j=1..3，i=2 走到 j=2 就整体退出
END;

CALL p_loop_nested();                          -- 共 5 行：(1,1)(1,2)(1,3)(2,1)(2,2)

# 嵌套时 LEAVE 后面跟哪个标签，就跳到哪一层，这是“跳出多层循环”的唯一写法；
# 标签名建议取得有区分度（outer_loop / inner_loop），嵌套里都叫 loop 的话很难看清跳的是哪一层。

-- 4. LEAVE 也能跳出一个带标签的 BEGIN...END 代码块（不一定是循环）
DROP PROCEDURE IF EXISTS p_leave_block;
CREATE PROCEDURE p_leave_block(IN v INT, OUT msg VARCHAR(50))
BEGIN
    block_one: BEGIN                       -- 代码块也可以带标签
        IF v < 0 THEN
            SET msg := '负数，提前跳出代码块';
            LEAVE block_one;               -- 直接跳到 END block_one 之后，后面的语句都不执行
        END IF;
        SET msg := CONCAT('处理完成：', v);
    END block_one;
END;

CALL p_leave_block(-1, @msg);
SELECT @msg;                                   -- 负数，提前跳出代码块
CALL p_leave_block(10, @msg);
SELECT @msg;                                   -- 处理完成：10

-- 5. 三种循环对比：同一个任务（1 到 n 求和）用 LOOP / WHILE / REPEAT 各写一遍
# LOOP   ：无条件的死循环，退出条件自己写 LEAVE，判断位置随意 → 最灵活，也最容易写出死循环
# WHILE  ：先判断后执行，条件为真才进循环体，可能一次都不执行
# REPEAT ：先执行后判断，至少执行一次，UNTIL 后面写的是“退出条件”（注意和 WHILE 相反）

DROP PROCEDURE IF EXISTS p_while_sum;
CREATE PROCEDURE p_while_sum(IN n INT, OUT total INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    SET total := 0;
    WHILE i <= n DO                        -- 这里写的是“继续条件”，和 REPEAT 的 UNTIL 相反
        SET total := total + i;
        SET i := i + 1;
    END WHILE;
END;

DROP PROCEDURE IF EXISTS p_repeat_sum;
CREATE PROCEDURE p_repeat_sum(IN n INT, OUT total INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    SET total := 0;
    REPEAT
        SET total := total + i;
        SET i := i + 1;
    UNTIL i > n END REPEAT;                -- UNTIL 后面写“什么时候退出”，条件为真就结束
END;

CALL p_while_sum(100, @w);
CALL p_repeat_sum(100, @r);
SELECT @w, @r;                             -- 都是 5050

CALL p_while_sum(0, @w);
CALL p_repeat_sum(0, @r);
SELECT @w, @r;                             -- WHILE 得 0，REPEAT 得 1
# 这就是“先判断”和“后判断”的差别：n=0 时 WHILE 一次都没进去，REPEAT 硬算了一轮。
# 反过来，如果业务上要求“至少执行一次”（比如先取一次数据再决定要不要继续），就用 REPEAT。

-- 6. 实战：用循环做批量插入（顺便看清循环的性能问题）
DROP TABLE IF EXISTS emp_loop_demo;
CREATE TABLE emp_loop_demo (
    id     INT PRIMARY KEY,
    name   VARCHAR(50),
    salary DECIMAL(10, 2)
);

DROP PROCEDURE IF EXISTS p_loop_insert;
CREATE PROCEDURE p_loop_insert(IN cnt INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    ins_loop: LOOP
        IF i > cnt THEN
            LEAVE ins_loop;
        END IF;
        INSERT INTO emp_loop_demo (id, name, salary)
        VALUES (i, CONCAT('批量员工', i), 5000 + i * 100);
        SET i := i + 1;
    END LOOP ins_loop;
END;

CALL p_loop_insert(100);
SELECT COUNT(*), MIN(salary), MAX(salary) FROM emp_loop_demo;   -- 100 行，5100 ~ 15000

# 注意：循环里一条一条 INSERT 是“逐行提交”，每行都要走一次解析 + 事务，数据量一大就非常慢。
# 能写成一条集合操作就别用循环，同样的结果下面这一条 SQL 就够了：
# INSERT INTO emp_loop_demo (id, name, salary)
# SELECT n, CONCAT('批量员工', n), 5000 + n * 100
# FROM (WITH RECURSIVE seq(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 100)
#       SELECT n FROM seq) t;
# 循环更适合场景本身就必须逐行处理的活：逐行校验、调外部接口、按行做不同分支。

-- 收尾：练习完清理掉
DROP PROCEDURE IF EXISTS p_loop_sum;
DROP PROCEDURE IF EXISTS p_loop_iterate;
DROP PROCEDURE IF EXISTS p_loop_nested;
DROP PROCEDURE IF EXISTS p_leave_block;
DROP PROCEDURE IF EXISTS p_while_sum;
DROP PROCEDURE IF EXISTS p_repeat_sum;
DROP PROCEDURE IF EXISTS p_loop_insert;
DROP TABLE IF EXISTS emp_loop_demo;

# LOOP 踩坑清单：
# 1. 死循环：LOOP 一定要有 LEAVE 出口，计数器自增不能写在 ITERATE 后面。
# 2. LEAVE / ITERATE 后面必须带标签，MySQL 没有 break / continue 关键字。
# 3. ITERATE 只能用在循环里；LEAVE 除了循环，还能跳出带标签的 BEGIN...END。
# 4. LEAVE 跟的是哪层的标签就跳哪层，嵌套循环跳出多层只能靠给外层标签。
# 5. 循环变量用 DECLARE 声明，别和输入参数重名，否则 SET 改的是参数不是变量，容易出诡异结果。
# 6. 存储过程里的死循环 max_execution_time 管不住，只能另外开个连接 KILL 掉。
# 7. DataGrip 里整段执行没问题；但如果用 mysql 命令行客户端，CREATE PROCEDURE 里的分号
#    会被当成语句结束，得先写 DELIMITER $$，过程写完再 DELIMITER ; 改回来。
