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
set global autocommit = 1; -- 设置全局级别的变量 = SET @@autocommit = 1;
set session autocommit  = 1; -- 设置会话级别的变量 = SET @@session.autocommit = 1;（注意不是 @autocommit，@ 开头的是用户自定义变量，两回事）
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
       SUM(CASE WHEN salary < 8000 THEN 1 ELSE 0 END)   AS `低薪人数`
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
    set r := total;
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
    set r := total;
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


# ========================================================游标============================================================
-- 声明游标
-- 声明游标
CREATE PROCEDURE FUN7()
BEGIN
    declare done boolean default false;
    declare c_id int;
    declare c_name varchar(255);
    declare c_salary int ;-- 声明局部变量用来接收fetch输出的数据

    DECLARE cursor1 CURSOR FOR
        SELECT id, name, salary
        FROM employee; -- 创建游标cursor
    declare continue handler for not found
        set done := true; -- 创建处理程序，处理程序的声明不能在游标之后
    open cursor1; -- 打开一个游标
    my_loop : loop
        if done then
            leave my_loop;
        end if;
    fetch cursor1 into c_id, c_name, c_salary;-- 每执行一次 FETCH，游标就尝试读取下一条记录，而不是每次都读取第一条
        end loop;
    close cursor1;
end;
call FUN7();
drop procedure FUN7;
-- HANDLER 并不是主动检查 FETCH。
-- 它提前声明了一个条件处理规则：
-- 当 FETCH 没有下一条记录时，MySQL 自动产生 NOT FOUND 条件；
-- HANDLER 捕获该条件，并执行 SET done = TRUE；
-- 因为使用 CONTINUE，所以程序继续执行 FETCH 后面的 IF 判断；
-- 最终通过 LEAVE 退出循环。


# ============================================条件处理程序（HANDLER）===========================================
USE lyt;

# 条件处理程序 = 存储程序里的 try / catch：
# 在块的开头提前声明一条规则 ——“如果发生了 X 条件，就执行 Y 语句”，
# 之后这个块里任何语句触发 X，都会自动跳到 Y。
#
# 它和 IF 的区别：
#   IF      是主动检查 —— 先算条件，再决定走哪条分支，事前知道有几种情况；
#   HANDLER 是被动捕获 —— 出事才触发，用来对付“不知道会不会发生、发生了程序就会中断”的错误。
#
# 语法结构：
# DECLARE handler_action HANDLER
#     FOR condition_value [, condition_value] ...
#     statement
#
# handler_action（处理完之后的动作）：
#   CONTINUE  处理完，从“出错那条语句之后”接着往下执行
#   EXIT      处理完，直接结束声明它的那个 BEGIN...END 块（哪怕错误发生在更内层）
#   UNDO      MySQL 不支持，写了直接语法报错
#
# condition_value（触发条件，六选一）：
#   1062                MySQL 错误码，精确匹配
#   SQLSTATE '23000'    SQLSTATE 值，精确匹配
#   condition_name      用 DECLARE ... CONDITION 起的别名
#   SQLWARNING          SQLSTATE 以 '01' 开头的一类（警告）
#   NOT FOUND           SQLSTATE 以 '02' 开头的一类（游标取完 / SELECT INTO 没查到）
#   SQLEXCEPTION        SQLSTATE 不以 '00'/'01'/'02' 开头的一类（真正的错误，最常用）
#
# 声明位置（顺序不能乱，这是硬规定）：
#   变量 / 条件声明  →  游标声明  →  处理程序声明  →  可执行语句
#   处理程序必须写在变量和游标之后、可执行语句之前；顺序写反报 1337。
#
# 没声明处理器时的默认动作（很多“程序莫名中断”就是它）：
#   SQLEXCEPTION  在出错语句处直接终止程序（相当于自带的 EXIT）
#   SQLWARNING    继续执行（相当于自带的 CONTINUE）
#   NOT FOUND     正常产生时继续；由 SIGNAL / RESIGNAL 抛出时终止
#
# 条件三大类互斥，别搞混：
#   SQLWARNING   只接警告，不接错误
#   NOT FOUND    只接“没数据”，不接错误
#   SQLEXCEPTION 只接错误，不接上面两类

-- 0. 准备练习表（独立的表，不动 employee 真数据）
DROP TABLE IF EXISTS emp_handler_demo;
CREATE TABLE emp_handler_demo (
    id     INT PRIMARY KEY,
    name   VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2)
);
INSERT INTO emp_handler_demo (id, name, salary)
VALUES (1, '甲', 8000.00),
       (2, '乙', 12000.00);
SELECT * FROM emp_handler_demo;

-- 1. 先看“没有处理器”是什么下场：SQLEXCEPTION 默认 = 直接终止
DROP PROCEDURE IF EXISTS p_no_handler;
CREATE PROCEDURE p_no_handler()
BEGIN
    INSERT INTO emp_handler_demo VALUES (1, '重复甲', 9000);       -- 主键冲突，1062
    SELECT '这行不会输出：上面报错后程序已终止' AS msg;             -- 默认 EXIT，走不到这里
END;

CALL p_no_handler();   -- 报错 Duplicate entry '1' for key 'emp_handler_demo.PRIMARY'
DROP PROCEDURE IF EXISTS p_no_handler;
# 注意：这里连 CALL 都算“报错结束”，不会有任何结果集返回。
# 结论：想让程序在出错后继续跑，必须自己声明处理器，默认行为永远是终止。

-- 2. CONTINUE：捕获、处理、然后接着往下执行
DROP PROCEDURE IF EXISTS p_continue;
CREATE PROCEDURE p_continue()
BEGIN
    DECLARE CONTINUE HANDLER FOR 1062                              -- 只接主键冲突这一种错误
        SELECT '【处理器】捕获到 1062 主键冲突，继续执行' AS handle_msg;

    SET @x := 1;
    INSERT INTO emp_handler_demo VALUES (1, '重复甲', 9000);        -- 冲突 → 触发处理器
    SET @x := 2;                                                   -- CONTINUE：这句照常执行
    INSERT INTO emp_handler_demo VALUES (3, '丙', 7000);            -- 正常插入
    SET @x := 3;
    SELECT @x AS x;                                                -- 3，证明程序没被中断
END;

CALL p_continue();
SELECT * FROM emp_handler_demo;   -- 只多了 id=3；冲突那行不会进表
# 处理器只管“跳过这条出错的语句”，出错语句本身仍然失败（那行没插进去），不会帮你重试。

-- 3. EXIT：捕获、处理、然后整块结束
DROP PROCEDURE IF EXISTS p_exit;
CREATE PROCEDURE p_exit()
BEGIN
    DECLARE EXIT HANDLER FOR 1062
        SELECT '【处理器】捕获到 1062，登记一下，结束整个块' AS handle_msg;

    INSERT INTO emp_handler_demo VALUES (1, '重复甲', 9000);        -- 冲突 → 触发处理器
    INSERT INTO emp_handler_demo VALUES (4, '丁', 6000);            -- EXIT：这句不会执行
    SELECT '这句也不会执行' AS msg;
END;

CALL p_exit();
SELECT * FROM emp_handler_demo;   -- 没有 id=4
# EXIT / CONTINUE 是两种完全不同的收尾策略：
#   EXIT     —— 后面的业务逻辑不该在“前提已经坏了”的情况下继续跑（比如扣款失败就别再发货）
#   CONTINUE —— 单条失败不影响整体（比如批量导入跳过脏数据）

-- 4. 条件名（DECLARE ... CONDITION）：给错误码起个别名，处理程序里用名字写，可读性好很多
DROP PROCEDURE IF EXISTS p_cond_name;
CREATE PROCEDURE p_cond_name()
BEGIN
    DECLARE dup_key  CONDITION FOR SQLSTATE '23000';               -- 别名：违反完整性约束
    DECLARE CONTINUE HANDLER FOR dup_key
        SELECT '【处理器】SQLSTATE 23000：完整性约束被违反' AS handle_msg;

    INSERT INTO emp_handler_demo VALUES (1, '重复甲', 9000);        -- 1062 主键重复
    INSERT INTO emp_handler_demo VALUES (NULL, '空主键', 1000);     -- 1048 主键为 NULL
    SELECT '两条都出错，都被 CONTINUE 跳过，程序走到这里' AS msg;
END;

CALL p_cond_name();
# 1062 和 1048 是两个不同错误码，但 SQLSTATE 都是 23000，
# 所以一个 SQLSTATE '23000' 就同时接住了 —— 这正是“错误码”和“错误类”的区别：
#   错误码 / SQLSTATE  精确匹配，只接那一种；
#   SQLEXCEPTION 等类  模糊匹配，一个处理器接一大片（方便，也更容易误吞）。

-- 5. NOT FOUND：不只是游标取完才触发，SELECT ... INTO 查不到也会触发
DROP PROCEDURE IF EXISTS p_not_found;
CREATE PROCEDURE p_not_found()
BEGIN
    DECLARE v_name VARCHAR(50) DEFAULT '还没赋值';
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_name := '查无此人';                                   -- 没数据时给个兜底值

    SELECT name INTO v_name FROM emp_handler_demo WHERE id = 99;    -- 查不到 → SQLSTATE 02000
    SELECT v_name AS result;
END;

CALL p_not_found();   -- 查无此人
# 没有这个处理器的话，SELECT ... INTO 查不到会报 1329 No data，程序按错误处理直接终止。
# 反过来的坑：一旦声明了 NOT FOUND 处理器，块里“所有”查不到数据的语句都会静默走它，
# 包括你并不想忽略的那些 —— 作用域是整个块，不是某一条语句。

-- 6. SQLEXCEPTION 兜底 + GET DIAGNOSTICS 取错误详情
DROP PROCEDURE IF EXISTS p_diag;
CREATE PROCEDURE p_diag()
BEGIN
    DECLARE v_state VARCHAR(5);
    DECLARE v_no    INT;
    DECLARE v_msg   TEXT;
    DECLARE hit     INT DEFAULT 0;                                  -- 标志：处理器是否被触发
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION                       -- 一把梭：所有错误都接
        SET hit := 1;                                               -- 处理器只做标记，取错放在外面做

    INSERT INTO emp_handler_demo VALUES (5, '戊', 11000);           -- 正常
    INSERT INTO emp_handler_demo VALUES (6, NULL, 11000);           -- name NOT NULL → 1048
    IF hit = 1 THEN
        GET DIAGNOSTICS CONDITION 1
            v_state = RETURNED_SQLSTATE,
            v_no    = MYSQL_ERRNO,
            v_msg   = MESSAGE_TEXT;                                -- 从诊断区把错误详情抠出来
    END IF;
    INSERT INTO emp_handler_demo VALUES (7, '庚', 13000);           -- 前面出错也照样执行
    SELECT v_state AS `错误状态`, v_no AS `错误码`, v_msg AS `错误信息`;  -- 别名别写 sqlstate / errno：SQLSTATE 是 MySQL 关键字，errno 是内置函数名，不加反引号会报语法错误
END;

CALL p_diag();
# 处理器只知道“出错了”，错误码和错误原文要靠诊断区取：
#   GET DIAGNOSTICS CONDITION 1 ...   CONDITION 1 = 当前这一条诊断记录
#   RETURNED_SQLSTATE / MYSQL_ERRNO / MESSAGE_TEXT  最常用的三个字段
# 实战里至少把 v_msg 记进日志表，否则吞掉的错误永远查不出来。

-- 7. SIGNAL：主动抛错（做业务校验），也能被同类处理器接住
DROP PROCEDURE IF EXISTS p_signal;
CREATE PROCEDURE p_signal(IN v_salary DECIMAL(10, 2))
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
        SELECT '【处理器】捕获到自定义错误 45000' AS handle_msg;

    IF v_salary < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '薪水不能为负数';  -- 相当于 raise
    END IF;
    SELECT '校验通过' AS msg;
END;

CALL p_signal(-100);   -- 触发自定义错误，被处理器接住
CALL p_signal(8000);   -- 校验通过
# SQLSTATE '45000' 是留给用户自定义错误的通用值，不会和系统错误撞车，业务校验统一用它。

-- 8. RESIGNAL：处理器处理完再把错误抛给上层（catch 里 rethrow）
DROP PROCEDURE IF EXISTS p_inner;
CREATE PROCEDURE p_inner()
BEGIN
    DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
        SELECT '【内层】记日志：插入重复，转交给外层' AS log_msg;
        RESIGNAL;                                     -- 重抛当前错误
    END;

    INSERT INTO emp_handler_demo VALUES (1, '重复甲', 9000);        -- 冲突 → 内层处理器
    SELECT '内层后面的语句不会执行' AS msg;
END;

DROP PROCEDURE IF EXISTS p_outer;
CREATE PROCEDURE p_outer()
BEGIN
    DECLARE CONTINUE HANDLER FOR 1062
        SELECT '【外层】收到内层抛上来的 1062' AS handle_msg;

    CALL p_inner();                                   -- 内层 RESIGNAL → 由外层这个处理器接住
    SELECT '外层继续执行' AS msg;                      -- 外层是 CONTINUE，所以这句会执行
END;

CALL p_outer();
# RESIGNAL 之后内层自己的 CONTINUE 就不作数了，控制权交回外层 CALL 之后；
# 典型用法：底层只负责记录日志，最终怎么处理留给调用方决定。

-- 9. 处理器的作用域：条件先在“出错那一层块”里找处理器，找不到才往外层找
DROP PROCEDURE IF EXISTS p_scope;
CREATE PROCEDURE p_scope()
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION                      -- 外层兜底：什么错都管
        SELECT '【外层】兜底处理器' AS handle_msg;

    inner_block: BEGIN
        DECLARE CONTINUE HANDLER FOR 1062                          -- 内层：专门管主键冲突
            SELECT '【内层】专门管主键冲突' AS handle_msg;

        INSERT INTO emp_handler_demo VALUES (1, '重复甲', 9000);    -- 内外都能管 → 内层优先
    END inner_block;

    SELECT '程序继续执行到最后' AS msg;
END;

CALL p_scope();
# 内层声明更具体的处理器，外层留一个兜底，这是最实用的结构。
# 但同一个块里别写两个都可能命中的处理器 —— 谁生效不好维护，也容易踩坑。

-- 10. 实战：批量导入，只跳过“重复主键”，其他错误照常抛出
DROP TABLE IF EXISTS emp_import_demo;
CREATE TABLE emp_import_demo (
    id     INT PRIMARY KEY,
    name   VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2)
);
INSERT INTO emp_import_demo (id, name, salary) VALUES (2, '乙', 12000.00);   -- 先占个坑，等下会撞

DROP PROCEDURE IF EXISTS p_import;
CREATE PROCEDURE p_import()
BEGIN
    DECLARE v_i    INT DEFAULT 1;
    DECLARE v_skip INT DEFAULT 0;                      -- 统计被跳过的条数
    DECLARE CONTINUE HANDLER FOR 1062
        SET v_skip := v_skip + 1;                      -- 只对主键冲突计数并继续，其他错误不管

    ins_loop: LOOP
        IF v_i > 5 THEN
            LEAVE ins_loop;
        END IF;
        INSERT INTO emp_import_demo (id, name, salary)
        VALUES (v_i, CONCAT('员工', v_i), 5000 + v_i * 1000);
        SET v_i := v_i + 1;
    END LOOP ins_loop;

    SELECT v_skip AS `跳过的重复行`, (SELECT COUNT(*) FROM emp_import_demo) AS `表内总行数`;
END;

CALL p_import();   -- 跳过 1 行（id=2），表里 5 行
# 这就是“只忽略我关心的那一种错误”的标准写法：
# 条件写得越窄越安全；写成 SQLEXCEPTION 会把 name 为 NULL、字段超长这类真问题一起吞掉。
# 注意：跳过的行不会撤销前面已插入的行，要整体可控得自己包事务 + ROLLBACK。

-- 收尾：练习完清理
DROP PROCEDURE IF EXISTS p_no_handler;
DROP PROCEDURE IF EXISTS p_continue;
DROP PROCEDURE IF EXISTS p_exit;
DROP PROCEDURE IF EXISTS p_cond_name;
DROP PROCEDURE IF EXISTS p_not_found;
DROP PROCEDURE IF EXISTS p_diag;
DROP PROCEDURE IF EXISTS p_signal;
DROP PROCEDURE IF EXISTS p_inner;
DROP PROCEDURE IF EXISTS p_outer;
DROP PROCEDURE IF EXISTS p_scope;
DROP PROCEDURE IF EXISTS p_import;
DROP TABLE IF EXISTS emp_handler_demo;
DROP TABLE IF EXISTS emp_import_demo;

# HANDLER 踩坑清单：
# 1. 声明顺序：变量/条件 → 游标 → 处理程序 → 可执行语句，写反报 1337。
#    （前面游标那段注释里“处理程序的声明不能在游标之后”正好写反了，是必须在游标之后）
# 2. 作用域是整个块 + 内层块，不可能只对某几条语句生效：
#    声明了 CONTINUE HANDLER FOR NOT FOUND 之后，块里所有 SELECT ... INTO 查不到都会静默跳过。
# 3. 处理器里不能用 LEAVE / ITERATE 去跳外层块的标签，报 1308 LEAVE with no matching label。
#    想跳出 → 用 EXIT 处理器；想继续 → 在处理器里改一个标志变量，回到正常流程里判断。
# 4. 三大类互斥：SQLEXCEPTION 不接 NOT FOUND、也不接 SQLWARNING，别以为能一把全接。
# 5. 条件写太宽会吞真错误：SQLEXCEPTION 一把梭会把 NULL 违规、字段超长、表不存在全吃掉。
# 6. CONTINUE 不撤销已做的事：同一事务里出错前的 INSERT 还在，该 ROLLBACK 自己写。
# 7. 严格模式下很多“警告”会升级成错误（SQLSTATE 从 01 变成真错误），
#    SQLWARNING 处理器就接不住了 —— 排错时先确认 sql_mode。
# 8. 静默忽略某一类条件是合法写法：DECLARE CONTINUE HANDLER FOR SQLWARNING BEGIN END;
#    空块 = 什么都不做，这类警告直接扔掉。
# 9. 存进函数（FUNCTION）里别轻易吞错：函数是返回值的，吞掉的错误会变成“返回了个 NULL”，
#    调用方很难发现，宁可让它报错。
# 10. 处理器触发后诊断区仍有记录，排查问题时 SHOW WARNINGS / GET DIAGNOSTICS 能拿到原文。

# BEGIN...END 的作用：
# 1. BEGIN...END 用来将多条 SQL 语句组合成一个代码块。
# 2. BEGIN...END 可以嵌套，形成外层代码块和内层代码块。
# 3. 存储过程主体本身通常就有一层 BEGIN...END。
# 4. HANDLER 也可以使用 BEGIN...END 包裹多条处理语句。

# EXIT HANDLER 的退出范围：
# 1. EXIT HANDLER 执行自己的处理代码后，
#    会退出 HANDLER 声明所在的 BEGIN...END 代码块。
# 2. 不是退出 HANDLER 自己内部的 BEGIN...END。
# 3. 如果 HANDLER 声明在存储过程最外层，
#    通常意味着整个存储过程提前结束。
# 4. 如果 HANDLER 声明在内层 BEGIN...END，
#    则退出内层代码块，外层代码仍可继续执行。

# ============================================HANDLER 条件类型============================================

# 一、HANDLER 的六种条件指定方式：
#
# 1. MySQL 错误码：
#    指定某一种具体的 MySQL 错误。
#    例如：1062 表示主键或唯一索引重复。
#
# 2. SQLSTATE：
#    使用 SQL 标准状态码指定处理条件，由 5 个字符组成。
#    例如：'23000' 表示违反完整性约束。
#
# 3. condition_name：
#    使用自定义条件名称指定处理条件。
#    需要先通过 DECLARE CONDITION 声明条件名称。
#    例如：DECLARE duplicate_error CONDITION FOR 1062;
#         DECLARE CONTINUE HANDLER FOR duplicate_error ...
#
# 4. SQLWARNING：
#    捕获警告类条件，对应 SQLSTATE 以 '01' 开头的状态。
#
# 5. NOT FOUND：
#    捕获没有找到数据的条件，对应 SQLSTATE 以 '02' 开头的状态。
#    常用于游标 FETCH 读取完毕时的结束处理。
#
# 6. SQLEXCEPTION：
#    捕获普通 SQL 异常，对应不属于成功、警告、无数据类别的异常条件。
#
# 二、SQLSTATE 状态码分类：
#
# SQLSTATE 以 5 个字符组成，前两位表示条件类别：
#
# '00'：成功（SUCCESS）
#       表示 SQL 执行成功，不作为错误处理条件。
#
# '01'：警告（WARNING）
#       对应 SQLWARNING。
#
# '02'：没有找到数据（NOT FOUND）
#       对应 NOT FOUND。
#
# 其他类别：异常（EXCEPTION）
#           对应 SQLEXCEPTION。
#
# 三、重点区别：
#
# 1. MySQL 错误码：针对具体的 MySQL 错误，例如 1062。
# 2. SQLSTATE：使用标准状态码识别条件，例如 '23000'。
# 3. condition_name：给错误码或 SQLSTATE 起一个有意义的名称。
# 4. SQLWARNING、NOT FOUND、SQLEXCEPTION：属于通用条件类别。
#
# 注意：
# SQLEXCEPTION 并不是所有错误和警告的统称，
# 它不包括 SQLSTATE 以 '00'、'01'、'02' 开头的条件。

# ============================================存储函数（FUNCTION）===========================================
USE lyt;

# 存储函数和存储过程是一对兄弟，都是“把一段 SQL 逻辑存进数据库，起个名字反复调用”：
#   存储过程 PROCEDURE：没有返回值，用 CALL 调用，一整条语句跑完就结束
#   存储函数 FUNCTION ：必须有且只有一个返回值，能当“值”用 —— 可以塞进 SELECT、WHERE、ORDER BY 里
#
# 一句话记住区别：
#   过程是“做事”，函数是“算值”。
#   过程用 CALL 单独执行；函数写在表达式里，和 NOW()、CONCAT() 这些内置函数一个位置。
#
# 语法结构：
# CREATE FUNCTION 函数名(参数列表)
# RETURNS 返回类型
#     [characteristics]
# BEGIN
#     ...
#     RETURN 值;          -- 必须有 RETURN，函数靠它把结果交出去
# END;
#
# characteristics（特征声明，写在 RETURNS 之后、BEGIN 之前）：
#   DETERMINISTIC       同样的输入一定得到同样的输出（纯计算，不读不写表）
#   NO SQL              函数体里完全没有 SQL 语句
#   READS SQL DATA      函数体里只查数据（SELECT），不修改数据
#   MODIFIES SQL DATA   函数体里会修改数据（INSERT/UPDATE/DELETE）
#   CONTAINS SQL        默认值，函数体里有 SQL 但没说明类型
#   SQL SECURITY DEFINER / INVOKER   以创建者 / 调用者的权限执行
#
# 为什么必须写 DETERMINISTIC / NO SQL / READS SQL DATA 这三个之一：
#   只要开了 binlog（MySQL 8.0 默认开），创建函数时不做这个声明就会直接报错：
#   ERROR 1418: This function has none of DETERMINISTIC, NO SQL, or READS SQL DATA ...
#   原因是主从复制要靠这三者判断“函数在主库和从库执行结果是否一致”。
#   三种解法：声明特征（推荐）/ SET GLOBAL log_bin_trust_function_creators = 1 / 关 binlog（别这么干）。

-- 1. 最简单的函数：纯计算，不碰表
DROP FUNCTION IF EXISTS f_annual_salary;
CREATE FUNCTION f_annual_salary(
    p_salary  DECIMAL(10, 2),   -- 月薪
    p_months  INT               -- 发几个月
)
RETURNS DECIMAL(12, 2)          -- 返回值类型必须声明，而且只能有一个返回值
    DETERMINISTIC               -- 同样输入必然同样输出，纯算数，所以要声明
    NO SQL                      -- 函数体里一句 SQL 都没有
BEGIN
    IF p_salary IS NULL OR p_months IS NULL THEN
        RETURN NULL;            -- 入参为空直接返回 NULL，别让后面的乘法算出莫名其妙的值
    END IF;
    RETURN p_salary * p_months; -- RETURN 执行后函数立即结束，后面的语句不会再跑
END;

-- 调用：SELECT 里当普通函数用
SELECT f_annual_salary(8000, 13) AS `年薪（13薪）`;
SELECT f_annual_salary(NULL, 12) AS `入参为 NULL 的结果`;   -- NULL

-- 也能直接用在查询的列上：每行调用一次
SELECT id, name, salary,
       f_annual_salary(salary, 13) AS `年薪`
FROM employee
WHERE id <= 5;

# 注意：函数写在 SELECT 列表里，是“逐行调用”——返回 1496 行就执行 1496 次。
# 简单的算术还好，一旦函数体里带 SELECT 查表，性能会断崖式下跌，能写成 JOIN 就别用函数。

-- 2. 带条件判断的函数：成绩分级
DROP FUNCTION IF EXISTS f_grade;
CREATE FUNCTION f_grade(p_score INT)
RETURNS VARCHAR(10)
    DETERMINISTIC
    NO SQL
BEGIN
    DECLARE v_result VARCHAR(10);
    IF p_score IS NULL THEN
        SET v_result := '无成绩';
    ELSEIF p_score >= 90 THEN
        SET v_result := '优秀';
    ELSEIF p_score >= 75 THEN
        SET v_result := '良好';
    ELSEIF p_score >= 60 THEN
        SET v_result := '及格';
    ELSE
        SET v_result := '不及格';
    END IF;
    RETURN v_result;            -- 函数里每个分支最终都要能 RETURN 到，否则会报“函数没有返回值”
END;

SELECT f_grade(95), f_grade(80), f_grade(60), f_grade(30), f_grade(NULL);

# 和 CASE 表达式对比一下：同样的分级逻辑，CASE 写在一句 SQL 里更省事；
# 函数的价值在于“一次写好，到处复用”——多个报表都要分级时不用重复抄 CASE。

-- 3. 要查表的函数：必须声明 READS SQL DATA
DROP FUNCTION IF EXISTS f_dept_name;
CREATE FUNCTION f_dept_name(p_dept_id INT)
RETURNS VARCHAR(50)
    READS SQL DATA              -- 函数体里要 SELECT 查表 → 声明只读
    DETERMINISTIC               -- 同样的 id 查出来的部门名是固定的，可以算确定
BEGIN
    DECLARE v_name VARCHAR(50) DEFAULT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_name := '未知部门';   -- 查不到时给个默认值，而不是让整个查询报 1329 中断

    SELECT dept_name INTO v_name       -- 函数里查单个值只能用 SELECT ... INTO，不能直接返回结果集
    FROM department
    WHERE dept_id = p_dept_id
    LIMIT 1;                           -- INTO 只能接一行，加 LIMIT 防止多行报错

    RETURN IFNULL(v_name, '未知部门');  -- 查到 NULL 也兜一下
END;

SELECT f_dept_name(1) AS `部门1`, f_dept_name(9999) AS `不存在的部门`;

SELECT e.id, e.name, e.dept_id, f_dept_name(e.dept_id) AS `部门名`
FROM employee e
WHERE e.id <= 5;

# 这里能看到函数的短板：SELECT 里 5 行就要查 5 次 department 表。
# 换成 JOIN 只需要一次关联查询 —— 所以“查表类函数”只适合小结果集或单次调用，别在大查询里用。

-- 4. 函数的实际用法一：写进 WHERE / ORDER BY / HAVING
SELECT id, name, salary
FROM employee
WHERE f_annual_salary(salary, 12) > 240000    -- 函数放在 WHERE 里 → 索引必然失效，全表扫
ORDER BY f_annual_salary(salary, 12) DESC     -- ORDER BY 里用函数：没有索引能用，必然 filesort
LIMIT 10;
# 记住：WHERE 里出现函数，等于在列上做运算，本来能走的索引全部作废。
# 能写成 `salary > 20000` 就别写成 `f_annual_salary(salary, 12) > 240000`。

-- 5. 函数用在 UPDATE / INSERT 里
DROP TABLE IF EXISTS emp_func_demo;
CREATE TABLE emp_func_demo (
    id        INT PRIMARY KEY,
    name      VARCHAR(50),
    score     INT,
    grade     VARCHAR(10)
);
INSERT INTO emp_func_demo (id, name, score) VALUES (1, '甲', 92), (2, '乙', 78), (3, '丙', 55);

UPDATE emp_func_demo SET grade = f_grade(score);   -- 每行的 score 各自过一遍函数
SELECT * FROM emp_func_demo;

DROP TABLE IF EXISTS emp_func_demo;

-- 6. 递归：函数不能递归！递归只能用存储过程
# 先记住这条硬限制（官方原文：Stored functions cannot be used recursively.）：
#   存储函数  不能调用自己，也不能 A 调 B、B 再调回 A 这种间接递归 → 报 1424
#   触发器    同样不允许递归
#   存储过程  允许递归，但要用 max_sp_recursion_depth 放开深度（默认 0 = 禁止）
#   所以 max_sp_recursion_depth 这个名字里的 sp 就是 stored procedure —— 只对过程生效。
#
# 下面这段是“故意报错”的示范，理解限制即可，不要真跑：
# CREATE FUNCTION f_fact(p_n INT) RETURNS BIGINT DETERMINISTIC NO SQL
# BEGIN
#     IF p_n <= 1 THEN RETURN 1;
#     ELSE RETURN p_n * f_fact(p_n - 1);   -- 函数调自己 → ERROR 1424: Recursive stored functions and triggers are not allowed
#     END IF;
# END;
# 改 max_sp_recursion_depth 也没用，那是给过程用的，函数的递归是“根本不让你写”。

-- 正确做法：用存储过程实现递归阶乘
SET SESSION max_sp_recursion_depth = 10;   -- 放开过程递归深度，默认 0 = 一递归就报 1456

DROP PROCEDURE IF EXISTS p_fact;
CREATE PROCEDURE p_fact(IN p_n INT, OUT p_result BIGINT)
BEGIN
    IF p_n IS NULL OR p_n < 0 THEN
        SET p_result := NULL;
    ELSEIF p_n <= 1 THEN
        SET p_result := 1;                        -- 递归出口：一定要写，漏了就撞深度上限
    ELSE
        CALL p_fact(p_n - 1, p_result);           -- 过程调用自己
        SET p_result := p_result * p_n;
    END IF;
END;

CALL p_fact(5, @f5);
CALL p_fact(10, @f10);
SELECT @f5 AS `5的阶乘`, @f10 AS `10的阶乘`;   -- 120 / 3628800
DROP PROCEDURE IF EXISTS p_fact;

# 递归深度演示：depth 设成 3，算 5 的阶乘会超过层数 → 报 1456 Recursive limit exceeded
# SET SESSION max_sp_recursion_depth = 3;
# CALL p_fact(5, @r);   -- 1456
# SET SESSION max_sp_recursion_depth = 10;

# 实用建议：阶乘、树形结构向上找父节点这类需求，MySQL 8.0 优先用递归 CTE（WITH RECURSIVE），
# 不用写存储过程，还能直接参与 JOIN，比过程递归好用得多：
# WITH RECURSIVE seq(n, f) AS (
#     SELECT 1, 1
#     UNION ALL
#     SELECT n + 1, f * (n + 1) FROM seq WHERE n < 10
# )
# SELECT f AS `10的阶乘` FROM seq WHERE n = 10;

-- 7. 查看、删除函数
SHOW FUNCTION STATUS WHERE Db = 'lyt';                       -- 列出当前库所有函数
SHOW CREATE FUNCTION f_annual_salary;                        -- 看函数的完整定义
SELECT ROUTINE_NAME, ROUTINE_TYPE, DTD_IDENTIFIER            -- DTD_IDENTIFIER 就是返回类型
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'lyt'
  AND ROUTINE_TYPE = 'FUNCTION';

DROP FUNCTION IF EXISTS f_grade;
DROP FUNCTION IF EXISTS f_dept_name;
DROP FUNCTION IF EXISTS f_annual_salary;
# DROP FUNCTION 只删函数；DROP PROCEDURE 只删过程，两者不会互相影响（同名也不冲突）

# ====================函数里那些“做不到”的事（都是硬限制）====================
# 下面几条都是故意报错，理解限制即可，不需要真跑

# 1. 不能返回结果集
#    CREATE FUNCTION f_bad() RETURNS INT DETERMINISTIC
#    BEGIN
#        SELECT * FROM employee;   -- 报错 1415：Not allowed to return a result set from a function
#        RETURN 1;
#    END;
#    函数只能 RETURN 一个标量值。要返回多行多列 → 用存储过程。

# 2. 参数只能是 IN
#    CREATE FUNCTION f_bad2(INOUT x INT) RETURNS INT ...   -- 语法错误
#    OUT / INOUT 是过程的专利，函数天生只有一个出口：RETURN。

# 3. 不能用动态 SQL
#    SET @s = 'SELECT 1'; PREPARE stmt FROM @s;   -- 报错 1336：Dynamic SQL is not allowed in stored function or trigger

# 4. 不能控制事务
#    COMMIT; / ROLLBACK; 出现在函数体里 → 报错
#    事务控制属于调用方，函数只负责算值。

# 5. 不写特征声明 + 开了 binlog → 1418（前面讲过了）

# 6. 不能递归（最容易踩，因为语法上看着完全没问题）
#    RETURN p_n * f_fact(p_n - 1);   -- 报错 1424：Recursive stored functions and triggers are not allowed
#    官方原文：Stored functions cannot be used recursively.
#    注意：这不是“深度设小了点”，而是“根本不允许”。max_sp_recursion_depth 只对存储过程有效，
#    改它没有任何用。需要递归 → 用存储过程，或者用递归 CTE（WITH RECURSIVE）。

# 函数踩坑清单：
# 1. 每条执行路径都必须能 RETURN 到。IF 分支漏了 ELSE、循环外没有兜底 RETURN，都会报“函数没有返回值”。
# 2. 声明 DETERMINISTIC 就要真的确定。函数里用了 NOW()、RAND()、UUID() 还标 DETERMINISTIC，
#    主从复制会数据不一致 —— 这种该标 NOT DETERMINISTIC 或不标，并另想办法（真实场景尽量避免）。
# 3. SELECT ... INTO 一定要配 NOT FOUND 处理器 + LIMIT 1：查不到会报 1329，查到多行会报 1172。
# 4. 函数的参数名别和表里的列名重名（比如参数叫 salary、表里也有 salary），
#    MySQL 会优先当成列名，条件静默失效 —— 这是最难查的坑。参数统一加 p_ 前缀最稳。
# 5. 别在函数里改数据（INSERT/UPDATE/DELETE）。函数常被用在 SELECT 里，一旦有副作用，
#    同一条 SELECT 跑两次结果可能都不一样，还可能锁表。真要改数据用存储过程。
# 6. 函数在 SELECT 里是逐行执行的，能不能用 JOIN / CASE 平替，先想想。
# 7. WHERE 里用函数 = 索引失效，这是最常见的性能事故。
# 8. 函数不能递归（1424），触发器同样不能递归；只有存储过程可以，且要设 max_sp_recursion_depth。
# 9. 函数属于某个库，跨库调用要写全名：SELECT lyt.f_grade(90);
# 10. 命令行客户端创建函数同样要先 DELIMITER $$，否则函数体里的分号会把语句截断。
# 11. 删除重建函数不会清掉已有权限，但函数改名等于新对象，需要重新授权。

# 函数特性	             主要作用
# DETERMINISTIC	声明函数是否具有确定性
# CONTAINS SQL	声明函数包含 SQL 语句，但不读写数据
# NO SQL	        声明函数不包含 SQL 数据访问语句
# READS SQL DATA	声明函数读取数据库数据
# MODIFIES SQL DATA	声明函数可能修改数据库数据
# SQL SECURITY	指定函数使用谁的权限执行
# COMMENT	        给函数添加描述信息
# LANGUAGE SQL	声明函数使用的语言

# =======================================================触发器======================================================
USE lyt;

-- insert型触发器
DROP TABLE IF EXISTS emp_trigger_demo; -- 前置测试条件准备（名字要和下面 CREATE 的完全一致）
DROP TABLE IF EXISTS emp_trigger_log;

CREATE TABLE emp_trigger_demo(
    id INT PRIMARY KEY AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    salary DECIMAL(10,2) DEFAULT 0,   -- 原来是 DEFAULT -1，和下面“工资不能<0”的校验直接打架：
                                      -- 不写 salary 时取默认值 -1，触发器立刻报错，等于这张表永远插不进只给名字的行
    createtime DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

CREATE TABLE emp_trigger_log(
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    OPERATION_type VARCHAR(20),
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    detail VARCHAR(255),
    operation_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- 开始创建插入前触发器，检查插入内容是否合规

DROP TRIGGER IF EXISTS t_emp_before_insert;

CREATE TRIGGER t_emp_before_insert
    BEFORE INSERT ON emp_trigger_demo
    FOR EACH ROW
    BEGIN
        -- 检查姓名
        -- 坑：NEW.name = NULL 永远不成立（NULL 比较结果是 UNKNOWN，不是 TRUE），必须写 IS NULL
        IF NEW.name IS NULL OR TRIM(NEW.name) = '' THEN
        signal sqlstate '45000'
            set message_text = '员工姓名不能为空';
        end if;
        -- 检查工资
        IF NEW.salary < 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = '员工工资不能小于0';
        end if;
        -- 自动去除名字的前后空格（BEFORE 触发器里 SET NEW.列 才能改到真正落库的值）
        set NEW.name = trim(NEW.name);
    end;

-- AFTER 触发器要和 BEFORE 触发器挂在同一张表上，否则日志表永远是空的
DROP TRIGGER IF EXISTS t_employee_after_insert;   -- 忘了这句，第二次执行就报 1359 Trigger already exists

CREATE TRIGGER t_employee_after_insert
    AFTER INSERT ON emp_trigger_demo     -- 原来写的是 ON employee：测试往 demo 表插数据，这个触发器根本不会触发
        FOR EACH ROW
    BEGIN
        INSERT INTO emp_trigger_log(
                emp_id,
                operation_type,
                old_salary,
                new_salary,
                detail
            ) VALUES (
                new.id,
                'INSERT',                    -- 原来是 'INERT'，少个 S，不报错但日志里全是错别字
                NULL,
                NEW.salary,
                CONCAT('新增员工：', NEW.name)
                );
    end;

-- 测试 1：正常插入（不写 id，交给 AUTO_INCREMENT，重复执行也不会撞主键）
INSERT INTO emp_trigger_demo (name, salary) VALUES ('  WMS  ', 12345.67);
SELECT id, CONCAT('[', name, ']') AS `名字是否已去空格`, salary FROM emp_trigger_demo;
SELECT * FROM emp_trigger_log;   -- 应该有一条：INSERT / 12345.67 / 新增员工：WMS

-- 测试 2：空名字被拦住
# INSERT INTO emp_trigger_demo (name, salary) VALUES ('   ', 100);      -- ERROR 1644: 员工姓名不能为空
-- 测试 3：负工资被拦住
# INSERT INTO emp_trigger_demo (name, salary) VALUES ('张三', -100);    -- ERROR 1644: 员工工资不能小于0

# 这一套原来跑不通的四个原因：
# 1. DROP 的是 emp_trigger_demo，CREATE 的是 emp_triggter_demo —— 名字对不上，重复执行必报 1050 表已存在。
# 2. NEW.name = NULL 永远不成立，空值其实没被校验到（这次没出事只是因为 name 列是 NOT NULL，数据库自己拦了）。
# 3. AFTER 触发器挂在 employee 上，测试却往 emp_trigger_demo 插 —— 日志表一条都不会有，
#    SELECT * FROM emp_trigger_log 是空结果，看着像“触发器没生效”，其实是挂错表了。
# 4. salary DEFAULT -1 和“工资不能<0”互斥：只插名字时取默认 -1，必然报错。
#    另外 'INERT' 拼错、缺 DROP TRIGGER IF EXISTS，都属于不报错但要命的小地方。

-- 收尾：练习完清理
DROP TRIGGER IF EXISTS t_emp_before_insert;
DROP TRIGGER IF EXISTS t_employee_after_insert;
DROP TABLE IF EXISTS emp_trigger_demo;
DROP TABLE IF EXISTS emp_trigger_log;

-- 查看触发器
# SHOW TRIGGERS FROM lyt;
# SELECT TRIGGER_NAME, EVENT_MANIPULATION, ACTION_TIMING, EVENT_OBJECT_TABLE
# FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'lyt';

# ============================================UPDATE 型触发器===========================================
USE lyt;

# UPDATE 触发器最大的特点：OLD 和 NEW 同时可用
#   OLD.列   改之前的值（数据原来的样子，只读）
#   NEW.列   改之后的值（即将写入/已经写入的样子）
# 对比一下：
#   INSERT 触发器：只有 NEW（没有旧行）
#   DELETE 触发器：只有 OLD（没有新行）
#   UPDATE 触发器：OLD + NEW 都有，所以能把“改前 → 改后”完整记下来
#
# BEFORE UPDATE 和 AFTER UPDATE 的分工：
#   BEFORE UPDATE  能校验（不合法就 SIGNAL 拒绝），也能用 SET NEW.列 改写即将落库的值
#   AFTER  UPDATE  数据已经写进去了，只能读 OLD/NEW 用来记日志、同步其他表
#
# 一个重要前提：触发器必须挂在“已经存在的表”上。
# 上面那段收尾已经把 emp_trigger_demo / emp_trigger_log 都 DROP 了，
# 此时直接 CREATE TRIGGER ... ON emp_trigger_demo 会报 1146 Table doesn't exist。
# 所以下面先重建表，再建触发器。

-- 1. 重建练习用的两张表
DROP TABLE IF EXISTS emp_trigger_demo;
DROP TABLE IF EXISTS emp_trigger_log;

CREATE TABLE emp_trigger_demo(
    id INT PRIMARY KEY AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    salary DECIMAL(10,2) DEFAULT 0,
    createtime DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

CREATE TABLE emp_trigger_log(
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    OPERATION_type VARCHAR(20),
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    detail VARCHAR(255),
    operation_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- 2. 先造数据，再建触发器 —— 顺序很重要
# 如果反了（先建触发器再插初始数据），这几条初始 INSERT 也会被日志记下来，
# 日志里就分不清哪些是插入、哪些是修改了。练习时先插数据更清爽。
INSERT INTO emp_trigger_demo (name, salary) VALUES
    ('张三', 8000.00),
    ('李四', 12000.00),
    ('王五', 5000.00);
SELECT * FROM emp_trigger_demo;

-- 3. 建 UPDATE 触发器
DROP TRIGGER IF EXISTS t_emp_after_update;
CREATE TRIGGER t_emp_after_update
    AFTER UPDATE ON emp_trigger_demo
    FOR EACH ROW
BEGIN
    # 你原来的写法有两个会直接报错的点，这里改掉了：
    #   (1) 列清单写了 5 列，VALUES 里却给了 6 个值（多了一个 CURRENT_TIMESTAMP）
    #       → 报 1136 Column count doesn't match value count at row 1
    #       operation_time 有 DEFAULT CURRENT_TIMESTAMP，本来就不用传
    #   (2) 这一段执行时 emp_trigger_demo 已经被 DROP 了 → 报 1146 Table doesn't exist
    INSERT INTO emp_trigger_log (emp_id, operation_type, old_salary, new_salary, detail)
    VALUES (
        NEW.id,                                                            -- 主键没变，NEW.id 和 OLD.id 是同一个值
        'UPDATE',                                                          -- 建议统一大写，方便以后按 operation_type 统计
        OLD.salary,                                                        -- 改之前的薪水
        NEW.salary,                                                        -- 改之后的薪水
        CONCAT(OLD.name, ' 的薪水由 ', OLD.salary, ' 调整为 ', NEW.salary)   -- 改前改后拼成一句人话
    );
END;

-- 4. 测试一：改一个人的薪水 → 日志多一条
UPDATE emp_trigger_demo SET salary = 9000.00 WHERE name = '张三';
SELECT * FROM emp_trigger_log;
# 结果：1 条，old_salary=8000.00，new_salary=9000.00
#       detail = 张三 的薪水由 8000.00 调整为 9000.00

-- 5. 测试二：一次 UPDATE 影响多行 → 触发器逐行执行，记多条
UPDATE emp_trigger_demo SET salary = salary * 1.1;
SELECT log_id, emp_id, operation_type, old_salary, new_salary, detail
FROM emp_trigger_log ORDER BY log_id;
# 结果：又多 3 条（张三 9000→9900、李四 12000→13200、王五 5000→5500）
# 这就是 FOR EACH ROW 的含义：影响 3 行，触发器就跑 3 次
# 反过来说，10 万行的批量 UPDATE 会跑 10 万次触发器，性能要提前掂量

-- 6. 测试三：值没变也会触发（新手最容易意外的行为）
UPDATE emp_trigger_demo SET salary = salary WHERE name = '李四';
SELECT COUNT(*) AS `日志总条数` FROM emp_trigger_log;
# 结果：又多一条，而且 old_salary 和 new_salary 一模一样
# 原因：MySQL 触发器只认“事件发生了”，不判断“值有没有变”。
#       只要 UPDATE 匹配到了这一行，就触发一次。
# 想只记录真正发生变化的行，要么在触发器里加判断（见下面第 7 步），
# 要么在外面写 UPDATE ... WHERE salary <> 新值 来收窄范围。

-- 7. 测试四：只改名字，salary 没动
UPDATE emp_trigger_demo SET name = '张三丰' WHERE id = 1;
SELECT * FROM emp_trigger_log ORDER BY log_id DESC LIMIT 1;
# 结果：照样记一条，old_salary = new_salary = 9900.00
# 说明触发器只认“表被 UPDATE 了”，不认“哪个列被改了”。
# 要精确追踪某个字段，就得在触发器里逐列比较：
#   IF NOT (OLD.name <=> NEW.name) THEN ... 记一条“改名”...
#   IF NOT (OLD.salary <=> NEW.salary) THEN ... 记一条“调薪”...

-- 8. 优化版：只有薪水真变了才记日志
#   <=> 是 NULL 安全的等于：NULL <=> NULL 为真，NULL <=> 9000 为假。
#   用 <> 或 != 的话，NULL 参与比较结果是 UNKNOWN，会漏掉情况。
DROP TRIGGER IF EXISTS t_emp_after_update;
CREATE TRIGGER t_emp_after_update
    AFTER UPDATE ON emp_trigger_demo
    FOR EACH ROW
BEGIN
    IF NOT (OLD.salary <=> NEW.salary) THEN
        INSERT INTO emp_trigger_log (emp_id, operation_type, old_salary, new_salary, detail)
        VALUES (
            NEW.id,
            'UPDATE',
            OLD.salary,
            NEW.salary,
            CONCAT(OLD.name, ' 的薪水由 ', OLD.salary, ' 调整为 ', NEW.salary)
        );
    END IF;
END;

-- 验证优化效果：跑一次“值不变”的 UPDATE，日志条数应该不再增长
SELECT COUNT(*) AS `改动前条数` FROM emp_trigger_log;
UPDATE emp_trigger_demo SET salary = salary;                 -- 值没变 → 不记日志
SELECT COUNT(*) AS `值不变的UPDATE后` FROM emp_trigger_log;   -- 条数不变
UPDATE emp_trigger_demo SET salary = 10000 WHERE name = '王五'; -- 值变了 → 记一条
SELECT COUNT(*) AS `值真变了之后` FROM emp_trigger_log;        -- 条数 +1

-- 9. 配套：BEFORE UPDATE 做校验（可选，演示分工）
# 校验放 BEFORE，日志放 AFTER —— 这是最标准的组合：
# BEFORE 能拦下非法数据，AFTER 才记录“已经成功落库”的变更。
DROP TRIGGER IF EXISTS t_emp_before_update;
CREATE TRIGGER t_emp_before_update
    BEFORE UPDATE ON emp_trigger_demo
    FOR EACH ROW
BEGIN
    IF NEW.salary < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '工资不能小于 0';
    END IF;
    SET NEW.name = TRIM(NEW.name);   -- BEFORE 才能改到即将落库的值
END;

-- 测试五：非法薪水被拦住
# UPDATE emp_trigger_demo SET salary = -100 WHERE name = '李四';   -- ERROR 1644: 工资不能小于 0

-- 测试六：改名字时自动去空格
UPDATE emp_trigger_demo SET name = '  赵六  ' WHERE id = 3;
SELECT id, CONCAT('[', name, ']') AS `名字是否已去空格` FROM emp_trigger_demo WHERE id = 3;
# 结果：[赵六]

-- 10. 完整看一遍三张视图
SELECT * FROM emp_trigger_demo;                              -- 当前数据
SELECT * FROM emp_trigger_log ORDER BY log_id;                -- 变更历史
SELECT TRIGGER_NAME, EVENT_MANIPULATION, ACTION_TIMING, EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'lyt'; -- 这个库里到底挂了哪些触发器

-- 收尾：练习完清理
DROP TRIGGER IF EXISTS t_emp_before_update;
DROP TRIGGER IF EXISTS t_emp_after_update;
DROP TABLE IF EXISTS emp_trigger_demo;
DROP TABLE IF EXISTS emp_trigger_log;

# UPDATE 触发器踩坑清单：
# 1. 触发器必须建在已存在的表上，先 DROP TABLE 再 CREATE TRIGGER 会报 1146。
# 2. INSERT 的列清单和 VALUES 个数必须一致，多给一个值就报 1136（你原来的写法就是这个）。
# 3. 值没变也会触发：触发器只认事件，不认变化。要去重请在触发器里用 <=> 判断。
# 4. 判断“有没有变”用 <=> 别用 <>：<> 遇到 NULL 返回 UNKNOWN，会静默漏判。
# 5. 一次多行 UPDATE，触发器逐行跑；批量操作前先想想性能。
# 6. BEFORE 里 SET NEW.列 才生效，AFTER 里改 NEW 无效（数据已经落库了）。
# 7. AFTER 触发器里不能对“正在被更新的那张表”再 UPDATE/INSERT，会报 1442；日志写别的表。
# 8. OLD 是只读的，任何 SET OLD.列 都会报错。
# 9. 主键被 UPDATE 改动时，NEW.id 是新值、OLD.id 是旧值，日志里记哪个要想清楚。
# 10. 触发器对应用层是隐形的，排错时先 SHOW TRIGGERS 看有没有“看不见的手”在改数据。

# ============================================DELETE 型触发器===========================================
USE lyt;

# DELETE 触发器和 INSERT 正好相反：只有 OLD，没有 NEW。
#   INSERT 触发器：只有 NEW（新行还没落库 / 刚落库）
#   UPDATE 触发器：OLD + NEW 都有（改前 → 改后）
#   DELETE 触发器：只有 OLD（被删掉的那一行，删完就没了）
# 为什么没有 NEW？因为删除之后没有“新行”这个东西。写 NEW.xxx 会直接报
#   ERROR 1363: There is no NEW row in the trigger
#
# BEFORE DELETE 和 AFTER DELETE 的分工（这里和 UPDATE 很不一样）：
#   BEFORE DELETE  还能拦住删除：SIGNAL 抛错 → 这条 DELETE 失败，行不会被删
#   AFTER  DELETE  行已经删掉了，只能“事后记录”，没法反悔
#
# 最常见的用途：把删掉的数据记到日志/归档表里，相当于软删除的兜底证据。
# 注意：AFTER DELETE 只是“记了一笔”，数据本身是真的没了。
# 想真能还原，就得把整行字段都存进归档表（下面第 8 步演示）。

-- 1. 重建练习用的两张表（上面收尾已经 DROP 过，不重建会报 1146 Table doesn't exist）
DROP TABLE IF EXISTS emp_trigger_demo;
DROP TABLE IF EXISTS emp_trigger_log;

CREATE TABLE emp_trigger_demo(
    id INT PRIMARY KEY AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    salary DECIMAL(10,2) DEFAULT 0,
    createtime DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

CREATE TABLE emp_trigger_log(
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    OPERATION_type VARCHAR(20),
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    detail VARCHAR(255),
    operation_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- 2. 先造数据，再建触发器
INSERT INTO emp_trigger_demo (name, salary) VALUES
    ('张三', 8000.00),
    ('李四', 12000.00),
    ('王五', 5000.00),
    ('赵六', 9000.00);
SELECT * FROM emp_trigger_demo;

-- 3. 建 DELETE 触发器
DROP TRIGGER IF EXISTS t_emp_after_delete;
CREATE TRIGGER t_emp_after_delete
    AFTER DELETE ON emp_trigger_demo
    FOR EACH ROW
BEGIN
    # 你原来的写法有三处要改（下面都修掉了）：
    #   (1) operation_type 写的是 'UPDATE' —— 从 UPDATE 触发器复制过来忘了改，
    #       不报错，但日志里所有删除记录都显示成“修改”，以后按类型统计就是错的。
    #   (2) 这段接在“收尾：练习完清理”之后，那时 emp_trigger_demo 已被 DROP，
    #       执行到这里会报 1146 Table doesn't exist。
    #   (3) 没有测试语句，触发器建完了也不知道到底灵不灵。
    #
    # 写对了的地方：用 OLD 而不是 NEW（DELETE 里写 NEW 会报 1363）、
    #               4 列对 4 值（不像 UPDATE 那段多给了一个 CURRENT_TIMESTAMP）、
    #               operation_time 靠默认值自动填 —— 这些都保留。
    INSERT INTO emp_trigger_log (emp_id, operation_type, old_salary, detail)
    VALUES (
        OLD.id,                                                   -- 被删掉那行的主键
        'DELETE',                                                 -- 别忘了改：DELETE 事件记 'DELETE'
        OLD.salary,                                               -- 删除前的薪水，留个底
        CONCAT('删除员工：id=', OLD.id, '，姓名=', OLD.name, '，薪水=', OLD.salary)
    );
END;

-- 4. 测试一：删一行 → 日志多一条
DELETE FROM emp_trigger_demo WHERE name = '张三';
SELECT * FROM emp_trigger_demo;            -- 只剩 3 行
SELECT * FROM emp_trigger_log;             -- 1 条：DELETE / old_salary=8000.00 / 删除员工：id=1...
# 注意 log 里的 old_salary 是从 OLD 拿的，行已经不在 demo 表里了，只有日志还记得它

-- 5. 测试二：一次删多行 → 触发器逐行执行，记多条
DELETE FROM emp_trigger_demo WHERE salary < 10000;
SELECT log_id, emp_id, operation_type, old_salary, detail
FROM emp_trigger_log ORDER BY log_id;
# 结果：李四 12000 留下；王五 5000、赵六 9000 被删 → 日志又 +2 条
# 这就是 FOR EACH ROW：删 2 行就跑 2 次触发器

-- 6. 测试三：DELETE 全表 → 每一行都记一笔（危险点）
# DELETE FROM emp_trigger_demo;    -- 4 行就 4 条日志；要是 100 万行，日志表瞬间爆掉
# 所以 DELETE 一定要带 WHERE，尤其是挂了 DELETE 触发器的表。
# 而 TRUNCATE TABLE 不触发 DELETE 触发器（它不算 DML），数据照样没了、日志一条没有 ——
# 这一点最容易被误判成“触发器失效了”。

-- 7. 测试四：DELETE 不存在的行 → 触发器不触发
DELETE FROM emp_trigger_demo WHERE id = 99999;
SELECT COUNT(*) AS `日志条数应无变化` FROM emp_trigger_log;
# 匹配 0 行就不会触发。触发器只认“真的删掉了一行”。

-- 8. 真正能还原的写法：归档整行
# 只记 id/name/salary 是“有据可查”，但真要恢复还得靠别的表。
# 想做到“删了能一键还原”，就建一张结构相同的归档表，把整行塞进去。
DROP TABLE IF EXISTS emp_archive;
CREATE TABLE emp_archive LIKE emp_trigger_demo;          -- LIKE：只复制结构，不复制数据
ALTER TABLE emp_archive
    ADD COLUMN archived_at DATETIME DEFAULT CURRENT_TIMESTAMP;  -- 记一下什么时候被归档的

DROP TRIGGER IF EXISTS t_emp_archive_delete;
CREATE TRIGGER t_emp_archive_delete
    AFTER DELETE ON emp_trigger_demo
    FOR EACH ROW
BEGIN
    INSERT INTO emp_archive (id, name, salary, createtime)
    VALUES (OLD.id, OLD.name, OLD.salary, OLD.createtime);   -- OLD 里每个字段都能拿到
END;

-- 测试五：删一行，归档表里能完整还原
INSERT INTO emp_trigger_demo (name, salary) VALUES ('孙七', 7700.00);
DELETE FROM emp_trigger_demo WHERE name = '孙七';
SELECT * FROM emp_archive;      -- 一条完整记录，想恢复就 INSERT INTO emp_trigger_demo SELECT ... FROM emp_archive
# 恢复语句示例（真要用时再放开）：
# INSERT INTO emp_trigger_demo (id, name, salary, createtime)
# SELECT id, name, salary, createtime FROM emp_archive WHERE id = ?;

-- 9. 配套：BEFORE DELETE 做“禁删”校验
# AFTER DELETE 只能事后记录，拦不住删除。要拦必须在 BEFORE DELETE 里 SIGNAL。
DROP TRIGGER IF EXISTS t_emp_before_delete;
CREATE TRIGGER t_emp_before_delete
    BEFORE DELETE ON emp_trigger_demo
    FOR EACH ROW
BEGIN
    IF OLD.salary > 20000 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '高薪员工不允许直接删除，请先走审批流程';
    END IF;
END;

-- 测试六：高薪被拦住
INSERT INTO emp_trigger_demo (name, salary) VALUES ('高管王', 30000.00);
# DELETE FROM emp_trigger_demo WHERE name = '高管王';   -- ERROR 1644: 高薪员工不允许直接删除...
SELECT COUNT(*) AS `高管王还在吗` FROM emp_trigger_demo WHERE name = '高管王';   -- 1，还在

-- 10. 看全貌
SELECT * FROM emp_trigger_demo;
SELECT * FROM emp_trigger_log ORDER BY log_id;
SELECT * FROM emp_archive;
SELECT TRIGGER_NAME, EVENT_MANIPULATION, ACTION_TIMING, EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'lyt';   -- 4 个触发器：BEFORE/AFTER × INSERT/UPDATE/DELETE 按需

-- 收尾：练习完清理
DROP TRIGGER IF EXISTS t_emp_before_delete;
DROP TRIGGER IF EXISTS t_emp_archive_delete;
DROP TABLE IF EXISTS emp_archive;
DROP TABLE IF EXISTS emp_trigger_demo;
DROP TABLE IF EXISTS emp_trigger_log;

# DELETE 触发器踩坑清单：
# 1. DELETE 里只能用 OLD，写 NEW 报 1363 There is no NEW row in the trigger。
# 2. operation_type 这类常量最容易复制粘贴写错（你这次就写成了 'UPDATE'），
#    不报错、不影响插入，但日志统计全错 —— 建完触发器一定要 SELECT 日志核对一眼。
# 3. 想拦住删除必须用 BEFORE DELETE + SIGNAL；AFTER DELETE 已经删完了，拦不住。
# 4. TRUNCATE 不触发 DELETE 触发器，数据照样清空、日志一条没有，别误判成触发器坏了。
# 5. DELETE 不带 WHERE = 全表逐行触发，100 万行就是 100 万次插入，日志表会爆。
# 6. 删 0 行不触发；只认“真的删掉了行”。
# 7. 删父表数据时外键 ON DELETE CASCADE 引起的级联删除，不会触发子表的 DELETE 触发器
#    （外键动作不激活触发器），要归档子表数据得另外处理。
# 8. AFTER DELETE 里不能对“正在被删的那张表”再 INSERT/UPDATE，报 1442；
#    归档请写别的表。真要在同表“复活”，得用 BEFORE DELETE 里插回去那种骚操作，不建议。
# 9. 归档表用 CREATE TABLE ... LIKE 建，结构天然一致；主键 id 原样保留才能还原。
# 10. 触发器对应用层隐形：数据“莫名其妙少了一行”时，先 SHOW TRIGGERS 看有没有删除触发器。

# ===========================================================锁=============================================================
USE lyt;

# MySQL 的锁按加锁范围分三层，从大到小：
#   全局锁  Global Lock        锁整个数据库实例 → 全库只读          FLUSH TABLES WITH READ LOCK
#   表级锁  Table Lock        锁一张表          → LOCK TABLES / MDL / 意向锁
#   行级锁  Row Lock          锁一行记录        → InnoDB 的 Record Lock / Gap Lock / Next-Key Lock
# 范围越大，并发越差：全局锁一上，整个库只能读；行级锁只挡冲突的那几行。
# 这一节讲全局锁，表级锁和行级锁在后面。

# ============================ 一、全局锁是什么 ============================
#
# 全局锁 = 给整个 MySQL 实例加一把“全局读锁”（Global Read Lock），
# 加锁期间全库进入只读状态：
#   能被阻塞：INSERT / UPDATE / DELETE（DML）
#             CREATE / ALTER / DROP / TRUNCATE（DDL）
#             以及“已经有修改的事务的 COMMIT”
#   不受影响：SELECT（读照常进行，这也是叫“读锁”的原因）
#
# 最典型（也几乎是唯一合理）的用途：全库逻辑备份时保证数据一致性。
#   不加锁的话，备份 A 表时业务在写 B 表，备份出来的两份数据可能对不上
#   （比如订单表已经备份完了，订单明细表才开始备份，中间又插入了几笔订单）。
#
# 它和 LOCK TABLES 的区别很容易搞混：
#   FLUSH TABLES WITH READ LOCK  锁的是“实例”，不用指定表名，影响全库
#   LOCK TABLES 表名 READ        锁的是“表”，只在当前会话有效，必须显式指定表
# 所以“全局锁”只有前者这一个入口。

-- 1. 加锁 / 解锁的基本写法
-- 添加全局锁
FLUSH TABLES WITH READ LOCK;   -- 简写 FTWRL；需要 RELOAD 权限
-- 进行备份操作（mysqldump、cp 数据文件等）

-- 释放锁
UNLOCK TABLES;                 -- 注意：它释放的是“当前会话持有的所有锁”，包括 LOCK TABLES 加的

-- 2. 加锁期间发生了什么（这个演示要开两个会话才看得到效果）
--    会话 A：FLUSH TABLES WITH READ LOCK;
--    会话 B：INSERT INTO lyt.employee (...) VALUES (...);   -- 卡住，一直等到锁释放
--    会话 B：SELECT * FROM lyt.employee LIMIT 1;            -- 正常返回，读不受影响
--    会话 A：UNLOCK TABLES;                                 -- 会话 B 的 INSERT 立刻执行完
--    注意：连“持锁的会话 A 自己”也写不进去，全局读锁对所有人一视同仁。

# ============================ 二、必须知道的六个特性 ============================
#
# 1. 会话级锁，不会永久卡死数据库
#    锁跟着“会话”走：UNLOCK TABLES 释放，或者会话断开（客户端崩溃、连接超时、
#    被 KILL）时自动释放。所以就算备份脚本中途挂了，也不会留下一把永远解不开的锁。
#    反过来说，这也是个隐患 —— 备份过程中连接一断，锁没了，备份还在继续跑，
#    这时业务又能写数据了 → 备份文件内部不一致。这就是很多备份脚本要“断开就重试”的原因。
#
# 2. FLUSH 语句会隐式提交
#    FLUSH 属于“导致隐式提交”的语句，执行前会先提交当前会话未提交的事务。
#    所以别在事务中间顺手加锁，事务边界会被它截断。
#
# 3. 加锁动作本身可能被卡住
#    执行 FTWRL 时，MySQL 要先把表都关一遍，会**等正在执行的语句/写事务结束**。
#    如果此时有一个长事务跑了 10 分钟，你的加锁语句就要陪着等 10 分钟。
#    线上加锁前先看一眼有没有长事务：
#      SELECT * FROM information_schema.INNODB_TRX ORDER BY trx_started;   -- 看有没有跑很久的事务
#      SHOW PROCESSLIST;                                                   -- 看有没有长查询
#
# 4. 在从库（replica）上执行，会拖慢复制
#    FTWRL 同样会阻塞复制线程里的 SQL 线程，从库上的数据变更应用不进来，
#    复制延迟（Seconds_Behind_Source）会一路往上涨。锁多久，延迟就涨多久。
#
# 5. 不要在业务高峰的主库上随手加
#    全局锁期间所有写请求全部阻塞。写入一堵，连接池很快被占满，
#    接着超时、重试、雪崩 —— 这是很典型的线上事故姿势。
#    真要备份，用下面第三节的替代方案，或者从从库备份。
#
# 6. 它不写 binlog
#    FLUSH TABLES WITH READ LOCK 不会记进 binlog（记了反而会在从库上引发问题）。

# ============================ 三、备份的四种做法对比 ============================
#
#   方案                              是否阻塞业务写     适用引擎            说明
#   ------------------------------    --------------    ----------------    --------------------------------
#   FLUSH TABLES WITH READ LOCK       是（全库只读）    任意引擎            万金油，代价最大
#   mysqldump --single-transaction    否（MVCC 快照）   仅 InnoDB           最常用的逻辑备份方式
#   LOCK INSTANCE FOR BACKUP          否（允许 DML）    仅 InnoDB           8.0 的备份锁，只挡 DDL
#   XtraBackup / MySQL Enterprise     否                仅 InnoDB           物理备份，靠 redo 保证一致
#
# 逐个说明：
#
# 1) mysqldump --single-transaction（InnoDB 首选）
#    它在 REPEATABLE READ 下开一个一致性快照，整个备份看到的是同一时刻的数据，
#    期间业务照常读写，完全不用加全局锁。
#    命令形如：
#      mysqldump -uroot -p --single-transaction --master-data=2 --databases lyt > lyt.sql
#    限制：只对支持事务的引擎有效。表里混了 MyISAM 就失去一致性保证
#          （mysqldump 遇到这种情况会退回去用 FTWRL）。
#
# 2) LOCK INSTANCE FOR BACKUP（MySQL 8.0 的备份锁）
#    这是 8.0 专门为备份设计的“实例级备份锁”，比 FTWRL 温和得多：
#      允许：DML（INSERT/UPDATE/DELETE 照常跑）
#      阻塞：DDL 等会破坏备份一致性的操作
#    需要 BACKUP_ADMIN 权限，用 UNLOCK INSTANCE 释放。
#    这也是 MySQL Enterprise Backup、Clone 插件这些工具内部用的机制。
#    LOCK INSTANCE FOR BACKUP;
#    -- 备份...
#    UNLOCK INSTANCE;
#
# 3) 那 FTWRL 还要不要学？
#    要。因为：混合引擎（MyISAM）备份、老版本环境、以及面试和各种文档里天天出现。
#    知道它“代价极大、能不用就别用”本身就是重点。
#
# 4) SET GLOBAL read_only = ON 不是全局锁，别搞混
#    它是“实例只读开关”，不是锁：
#      read_only=ON        普通用户不能写，但拥有 SUPER 权限的账号照样能写
#      super_read_only=ON  连 SUPER 也拦住（5.7 起才有），做真正只读更可靠
#    区别关键：read_only 期间没有“加锁等待”，它不参与锁竞争，是权限层面的限制。

# ============================ 四、怎么看当前有没有全局锁 ============================
-- 看全局锁（8.0 用 MDL 实现，可以在 metadata_locks 里看到）
SELECT OBJECT_TYPE, OBJECT_SCHEMA, OBJECT_NAME, LOCK_TYPE, LOCK_STATUS, OWNER_THREAD_ID
FROM performance_schema.metadata_locks
WHERE OBJECT_TYPE = 'GLOBAL' OR OBJECT_TYPE = 'COMMIT';
# OBJECT_TYPE='GLOBAL' 就是全局读锁；'COMMIT' 是配合它挡住事务提交的那把

-- 看是哪个线程持着锁，再顺藤摸瓜找到那条 SQL
SELECT THREAD_ID, PROCESSLIST_ID, PROCESSLIST_USER, PROCESSLIST_INFO
FROM performance_schema.threads
WHERE PROCESSLIST_INFO LIKE 'FLUSH TABLES%';

-- 看有没有被全局锁挡住、正在等待的会话
SELECT * FROM performance_schema.metadata_locks
WHERE LOCK_STATUS = 'PENDING';    -- PENDING = 正在排队等锁

-- 极简版：直接看进程列表，加锁的会显示 “Waiting for global read lock” 或本身是 FTWRL
SHOW PROCESSLIST;

# ============================ 五、踩坑清单 ============================
# 1. 备份期间连接断了，锁自动释放、备份继续跑 → 备份文件内部不一致。
#    脚本要能检测到这种情况并重做，或者干脆用 --single-transaction。
# 2. 长事务会把你自己的 FTWRL 卡住（加锁要等正在执行的写事务结束），
#    上线前先查 INNODB_TRX，别在有长事务时加锁。
# 3. 在从库上加锁会阻塞 SQL 线程 → 复制延迟暴涨，锁 5 分钟延迟就涨 5 分钟。
# 4. FTWRL 是“全库只读”，不是“只锁要备份的那张库”，影响面比你想要的大得多。
# 5. UNLOCK TABLES 释放的是当前会话的所有锁，如果你同时还 LOCK TABLES 了某张表，
#    一并被释放了，容易出“锁怎么莫名没了”的困惑。
# 6. 别把 read_only=ON 当全局锁用：SUPER 用户照样能写，要么用 super_read_only，
#    要么老老实实加锁。
# 7. 备份优先“从从库做”，别在主库上折腾；而且从库也别忘了它会拖慢复制。
# 8. FTWRL 只挡写和 DDL，不挡 SELECT —— 所以“加锁了业务怎么还在跑”是正常的，
#    读到的是锁加之前的数据。
# 9. 混引擎的表（InnoDB + MyISAM）用 --single-transaction 会失去一致性保证，
#    这种情况才真的需要 FTWRL。
# 10. 8.0 里优先考虑 LOCK INSTANCE FOR BACKUP：允许 DML、只挡 DDL，对业务友好得多。

# ========================================================= 表级锁 =========================================================
USE lyt;

# 表级锁不止“表锁”一种，MySQL 里其实有四类，平时最容易混：
#   1. 表锁       LOCK TABLES 手动加的读写锁 —— 本节主角，粒度粗，InnoDB 里基本不用
#   2. 元数据锁   MDL（Metadata Lock）—— 系统自动加，不用你写，但线上事故多半是它
#   3. 意向锁     IS / IX —— InnoDB 自动加，用来让“表锁”和“行锁”快速判断冲突
#   4. 自增锁     AUTO-INC —— 保证自增值不重复
# 下面按这个顺序讲。

# ============================ 一、表锁：READ 与 WRITE ============================
#
#                持锁会话自己        其他会话
#   READ  锁     只能读，不能写      能读（不用显式加锁），不能写 → 写请求排队等
#   WRITE 锁     能读也能写          读写都不行 → 全部排队等
#
# 记法：READ 是“共享锁”（大家都能读），WRITE 是“排他锁”（只有我能碰）。
#
# 另外两条容易忽略的：
#   持 READ 锁的会话不能 DROP TABLE / TRUNCATE TABLE（这俩算写操作）
#   持 WRITE 锁的会话可以 DROP TABLE / TRUNCATE TABLE
#
# READ LOCAL：比 READ 松一点，允许别的会话做“不冲突的并发 INSERT”（MyISAM 的 concurrent insert）。
#   注意：InnoDB 表上 READ LOCAL 和 READ 完全一样，没有区别。
# LOW_PRIORITY WRITE：已废弃，写了不报错但会给你一个 warning，行为等同 WRITE。别用。

-- 读锁（多个会话可以同时读取这张表，但是不能对这张表进行写操作。）
LOCK TABLES employee READ; -- 创建读锁
SELECT * FROM employee; -- 现在 employee 只能读不能写；其他会话也能读，但写请求会排队等这把锁释放
# 注意措辞：锁是“某个会话持有的”，不是“跟着表走”。
#   表只是被锁的对象，锁的归属是会话 —— 所以会话一断，锁就没了（见第四节）。
#   你原来写的“锁本质上是跟着表走的”容易让人以为锁是表的属性，改一下更准确。
# 自己也不能写：下面这句会报 1099 Table 'employee' was locked with a READ lock and can't be updated
# INSERT INTO employee (id, name, salary, age) VALUES (90250326, '测试', 100, 20);
UNLOCK TABLES; -- 释放锁

LOCK TABLES employee WRITE; --  创建写锁
SELECT * FROM employee;     -- 持锁会话自己读没问题
INSERT INTO lyt.employee (id, name, salary, age)
VALUES (90250325, '王梦燊', 12345.67, 20); -- 写锁既可以读取数据也可以写入数据，在锁未释放时其他会话无法对表进行任何操作
UNLOCK TABLES; -- 释放锁
# 提醒：这条 INSERT 重复执行会报 1062 主键冲突（id 写死了 90250325）。
# 练习时先 DELETE FROM employee WHERE id = 90250325; 再跑，或者每次换个 id。

-- 演示“别的会话被挡住”要开两个连接才看得到：
--   会话 A：LOCK TABLES employee WRITE;
--   会话 B：SELECT * FROM employee LIMIT 1;   -- 卡住（写锁连读都挡）
--   会话 A：UNLOCK TABLES;                    -- 会话 B 立刻返回
-- 对比 READ 锁：会话 A 持 READ 锁时，会话 B 的 SELECT 能正常返回，只有 INSERT/UPDATE 会卡。

# ============================ 二、写优先：读会被“饿死” ============================
#
# WRITE 锁的优先级高于 READ。这条规则的后果比想象的严重：
#   1. 会话 A 拿到 READ 锁
#   2. 会话 B 请求 WRITE 锁 → 排队等 A
#   3. 会话 C 请求 READ 锁 → 本来和 A 兼容，但因为 B 在排队，C 也得等！
# 也就是说：一个写请求插队，会把后面所有读请求一起堵住。
# 高并发读的表上，一个慢写操作能让整张表的查询全部超时。
# 这就是 InnoDB 要用行锁的根本原因 —— 别让一个写操作锁住整张表。

# ============================ 三、最大的坑：1100 未锁表 ============================
#
# 一旦执行了 LOCK TABLES，当前会话就进入“只能访问被锁表”的模式。
# 访问任何没在锁清单里的表 → ERROR 1100 Table 'xxx' was not locked with LOCK TABLES
#
# 所以：需要的所有表必须在一条 LOCK TABLES 里一次锁全，不能分两次加。
LOCK TABLES employee READ, department READ;   -- 一次锁全，两张表都能查
SELECT e.name, d.dept_name
FROM employee e JOIN department d ON d.dept_id = e.dept_id
LIMIT 5;
UNLOCK TABLES;

# 反例（会报 1100）：
# LOCK TABLES employee READ;
# SELECT * FROM department;      -- ERROR 1100：department 没在锁清单里
# UNLOCK TABLES;
#
# 唯一例外：information_schema 不用锁也能访问，所以持锁期间照样能查元数据：
LOCK TABLES employee READ;
SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'lyt';  -- 正常
UNLOCK TABLES;

# ============================ 四、别名必须对得上（很阴的坑） ============================
#
# 规则：查询里用什么名字引用表，就必须用什么名字加锁。
#
# 坑 1：锁的是原名，查的时候起了别名 → 报 1100
#   LOCK TABLES employee READ;
#   SELECT * FROM employee AS e;        -- ERROR 1100: Table 'e' was not locked with LOCK TABLES
#
# 坑 2：锁的是别名，查的时候用原名 → 同样报 1100
#   LOCK TABLES employee AS e READ;
#   SELECT * FROM employee;             -- ERROR 1100: Table 'employee' was not locked
#   SELECT * FROM employee AS e;        -- 这样才对
#
# 坑 3：同一条 SQL 里多次引用同一张表，必须给每个引用单独加锁
LOCK TABLES employee WRITE, employee AS e2 READ;   -- 原名和别名各锁一次
INSERT INTO employee (id, name, salary, age)
SELECT id + 1000000, name, salary, age FROM employee AS e2 WHERE id = 90250325;
UNLOCK TABLES;
# 不加 e2 那把锁就会报 1100 —— 因为一条语句里出现了两个对同表的引用。
# 练习完清掉这条派生数据：
DELETE FROM employee WHERE id = 1090250325;

# ============================ 五、锁怎么释放（四种途径） ============================
#
# 1. 显式：UNLOCK TABLES —— 一次释放当前会话的“全部”表锁，不能只放某一张
# 2. 隐式：再次执行 LOCK TABLES —— 新锁生效前，旧锁自动全部释放
# 3. 隐式：START TRANSACTION —— 开启事务会隐式 UNLOCK TABLES（这个最容易踩）
# 4. 隐式：连接断开 —— 正常退出或异常崩溃，服务器都会释放该会话所有表锁，
#          同时回滚它未提交的事务。所以不会留下“永远解不开的表锁”。
#
# 但第 4 条有个陷阱：客户端如果开了自动重连（auto-reconnect），
# 断线后悄悄重连成功，你以为锁还在，其实锁和事务全没了。
# 需要严格锁语义的程序应该关掉自动重连，让断线直接报错，好重新加锁。

# ============================ 六、和事务的关系（重点，容易出 bug） ============================
#
# 1. LOCK TABLES 不是事务安全的：执行它会“隐式提交”当前未提交的事务。
#    所以别在事务中间加表锁，事务边界会被它截断。
# 2. UNLOCK TABLES 也会隐式提交 —— 但仅当你之前用 LOCK TABLES 拿过表锁。
#    只加了 FTWRL（全局读锁）时，UNLOCK TABLES 只放锁、不提交事务。
# 3. START TRANSACTION 会隐式释放表锁 → 千万别用 START TRANSACTION 配 LOCK TABLES。
# 4. ROLLBACK 不释放表锁！回滚了事务，锁还在手上，必须自己 UNLOCK TABLES。
# 5. InnoDB 的内部表锁在下一次 COMMIT 时释放，MySQL 层的表锁要 UNLOCK TABLES 才释放。
#    autocommit=1 时 InnoDB 干脆不拿内部表锁，很容易死锁。
#
# 官方推荐的正确姿势（InnoDB + 表锁）：用 SET autocommit=0，不要用 START TRANSACTION
SET autocommit = 0;                  -- 关键：不是 START TRANSACTION
LOCK TABLES employee WRITE, department READ;
UPDATE employee SET salary = salary + 1 WHERE id = 90250325;
SELECT dept_name FROM department WHERE dept_id = 1;
COMMIT;                              -- 先显式提交
UNLOCK TABLES;                       -- 再释放锁，顺序不能颠倒
SET autocommit = 1;                  -- 练习完恢复默认，别把会话留在 autocommit=0
# 顺序记牢：SET autocommit=0 → LOCK TABLES → 干活 → COMMIT → UNLOCK TABLES

# ============================ 七、LOCK TABLES 和触发器 ============================
#
# 显式锁一张表时，它的触发器里用到的表会被“隐式一起锁上”：
#   触发器里只读的表 → 加读锁
#   触发器里会写的表 → 加写锁
#   而且：显式请求 READ，但触发器里要写这张表 → READ 会被自动升级成 WRITE
#
# 举例：LOCK TABLES t1 WRITE, t2 READ;
#   如果 t1 的触发器里 INSERT INTO t2 → t2 的 READ 请求被升级成 WRITE
#   如果 t1 的触发器里还读了 t3、改了 t4 → t3 加读锁、t4 加写锁（你没写它们也会被锁）
# 所以：给带触发器的表加表锁时，实际锁的范围比你写的大，排查阻塞时别漏了这些表。

# ============================ 八、表锁的硬限制 ============================
#
# 1. LOCK TABLES / UNLOCK TABLES 不能写在存储程序里（存储过程、函数、触发器都不行）。
#    这也是为什么前面那些过程和触发器演示里从来没出现过 LOCK TABLES。
# 2. performance_schema 里的表不能被 LOCK TABLES 锁（setup_xxx 那几张除外）。
# 3. 持锁期间禁止这些语句：CREATE TABLE、CREATE TABLE ... LIKE、CREATE VIEW、DROP VIEW，
#    以及对存储函数/过程/事件的 DDL。
# 4. TEMPORARY 表：LOCK TABLES 允许写但直接忽略 —— 临时表本来就只有当前会话能看见，不需要锁。
# 5. ALTER TABLE 可能让表锁失效：连着做第二次 ALTER 会报 1100，得重新加锁。
# 6. 正在等表锁的会话可以安全 KILL 掉（KILL <processlist_id>）。
# 7. 表锁只在“单个 MySQL 实例”内有效，NDB Cluster 那种多实例场景不生效。

# ============================ 九、元数据锁 MDL（线上事故重灾区） ============================
#

SELECT *
FROM performance_schema.metadata_locks; -- 查看系统中的所有MDL（元数据锁）锁

SELECT
    OBJECT_TYPE,       -- 锁定对象类型
    OBJECT_SCHEMA,     -- 数据库名称
    OBJECT_NAME,       -- 表名或对象名
    LOCK_TYPE,         -- MDL 锁类型
    LOCK_DURATION,     -- 锁持续时间
    LOCK_STATUS,       -- 锁状态
    OWNER_THREAD_ID    -- 持有锁的线程 ID
FROM performance_schema.metadata_locks;
-- 简略查询我们锁需要的内容
# MDL 是 MySQL 5.5 引入的，系统自动加，不用你写任何语句：
#   执行 SELECT / INSERT / UPDATE / DELETE → 自动加 MDL 读锁（共享）
#   执行 ALTER / DROP / TRUNCATE 等 DDL     → 自动加 MDL 写锁（排他）
# 目的：防止“一边查数据一边改表结构”导致读到不一致的元数据。
#
# 关键特性：MDL 在“事务结束”时才释放，不是语句执行完就放。
# 这就埋了一个经典雪崩：
#   1. 会话 A：BEGIN; SELECT * FROM employee;  然后一直不提交
#      → A 持有 employee 的 MDL 读锁，且因为事务没结束，锁一直不放
#   2. 会话 B：ALTER TABLE employee ADD COLUMN xxx INT;
#      → 要 MDL 写锁，被 A 挡住，开始等
#   3. 会话 C、D、E...：SELECT * FROM employee;
#      → 本来和 A 的读锁兼容，但 B 的写锁在排队（写优先），于是全部一起等
#   结果：一个忘了提交的事务 + 一条 ALTER，把整张表的所有查询全堵死。
#
# 这就是“给大表加字段前先看有没有长事务”的原因：
SELECT trx_id, trx_state, trx_started,
       TIMESTAMPDIFF(SECOND, trx_started, NOW()) AS `已运行秒数`, trx_mysql_thread_id
FROM information_schema.INNODB_TRX
ORDER BY trx_started;      -- 排在最前面的就是最老的事务，先看它是不是忘了提交

-- 看 MDL 的持有和等待情况
SELECT OBJECT_TYPE, OBJECT_SCHEMA, OBJECT_NAME, LOCK_TYPE, LOCK_DURATION, LOCK_STATUS, OWNER_THREAD_ID
FROM performance_schema.metadata_locks
WHERE OBJECT_SCHEMA = 'lyt';
# LOCK_STATUS = GRANTED 已拿到；PENDING 正在等
# LOCK_TYPE = SHARED_READ / SHARED_WRITE 是 DML 加的；EXCLUSIVE 是 DDL 加的
# 如果这张表查出来是空的，先确认 instrument 开着：
# UPDATE performance_schema.setup_instruments SET ENABLED='YES', TIMED='YES'
# WHERE NAME = 'wait/lock/metadata/sql/mdl';

-- 更省事：sys 库有现成的视图，直接告诉你“谁堵了谁”
SELECT * FROM sys.schema_table_lock_waits;
# 里面有 blocking_pid，可以直接 KILL 掉那个阻塞源（先确认它不是重要业务）

# ============================ 十、意向锁 IS / IX ============================
#
    START TRANSACTION ;
    SELECT *
    FROM employee
    WHERE id = 114514
    FOR SHARE; -- 手动添加意向共享锁
    commit ;

START TRANSACTION ;
SELECT *
FROM employee
WHERE id = 114514
    FOR update ; -- 手动添加意向排他锁
commit ;
# 问题：会话 A 锁了表里某一行（行锁），会话 B 想锁整张表（表锁），
#       B 怎么知道表里有没有行锁？难道逐行扫一遍？那太慢了。
# 解法：加行锁之前，先在“表”上打一个标记 —— 这就是意向锁。
#   要加行级共享锁（S）→ 先在表上加 IS（Intention Shared）
#   要加行级排他锁（X）→ 先在表上加 IX（Intention Exclusive）
# 于是 B 只要看表上有没有 IS/IX，一眼就知道能不能加表锁，不用扫行。
#
# 兼容性（记住这张表就够了）：
#            IS      IX      S(表共享)   X(表排他)
#   IS       兼容    兼容    兼容        冲突
#   IX       兼容    兼容    冲突        冲突
#   S        兼容    冲突    兼容        冲突
#   X        冲突    冲突    冲突        冲突
#
# 两个要点：
# 1. IS 和 IX 之间互相兼容 —— 因为它们只表示“我打算锁某些行”，具体冲不冲突交给行锁去判断。
#    所以意向锁不会降低行级操作的并发度。
# 2. 意向锁只和“表级锁”冲突，不和行锁冲突。它存在的唯一意义就是让表锁快速判断。
# 3. 意向锁是 InnoDB 自动加的，你写不了也不用写。

-- 看当前的锁（8.0 用 data_locks，5.7 是 INNODB_LOCKS）
SELECT ENGINE_TRANSACTION_ID, OBJECT_NAME, LOCK_TYPE, LOCK_MODE, LOCK_STATUS, LOCK_DATA
FROM performance_schema.data_locks;
# LOCK_TYPE = TABLE 且 LOCK_MODE = IX / IS → 就是意向锁
# LOCK_TYPE = RECORD → 行锁（下一节讲）
# 这张表要在“有事务正在持锁”时才看得到内容，空跑一条 SELECT 是看不到的
/*
================================================
         InnoDB 不同粒度锁的冲突关系
================================================

一、表级锁之间

1. IS + IS：兼容
2. IS + IX：兼容
3. IS + S ：兼容
4. IS + X ：冲突

5. IX + IX：兼容
6. IX + S ：冲突
7. IX + X ：冲突

8. S + S ：兼容
9. S + X ：冲突
10. X + 任何锁：冲突

二、行级锁之间（针对相同记录）

1. S + S：兼容
2. S + X：冲突
3. X + X：冲突

三、不同粒度之间

1. 表级 S 与行级 X 的申请冲突：
   - 行级 X 需要先申请表级 IX。
   - 表级 S 与 IX 冲突。

2. 表级 X 与行级 S 的申请冲突：
   - 行级 S 需要先申请表级 IS。
   - 表级 X 与 IS 冲突。

3. 表级 IX 与行级 X：
   - 可以兼容其他事务的 IX。
   - 不同记录上的 X 锁通常可以并发。
   - 同一记录上的 X 锁发生冲突。

四、判断锁冲突的原则

1. 先判断锁的粒度。
2. 再判断锁的模式。
3. 判断锁定对象是否重叠。
4. 根据兼容性矩阵判断是否冲突。
5. 注意间隙锁、临键锁可能产生范围冲突。

核心：
意向锁负责协调不同粒度的锁；
行锁负责协调具体记录的访问；
表级锁负责更大范围的访问控制。
*/
# ============================ 十一、自增锁 AUTO-INC ============================
#
# 往有 AUTO_INCREMENT 的表插数据时，InnoDB 要保证自增值不重复，于是有自增锁。
# 由 innodb_autoinc_lock_mode 控制三种模式：
#   0  traditional  表级 AUTO-INC 锁，整条 INSERT 语句期间都持有 → 并发最差
#   1  consecutive  简单 INSERT 用轻量 mutex 立刻释放；批量 INSERT ... SELECT 仍用表级锁
#   2  interleaved  全部用轻量 mutex，自增值可能不连续但保证唯一 → 并发最好（8.0 默认）
SHOW VARIABLES LIKE 'innodb_autoinc_lock_mode';
# 8.0 默认 2，因为默认用 row 格式复制，不再需要“自增值连续”这个保证。
# 所以：别依赖自增 id 连续，中间有空洞是正常的（回滚、并发插入都会留洞）。

# ============================ 十二、排查表锁的常用命令 ============================
-- 1. 看哪些表被显式锁着（In_use > 0 表示有会话正持有表锁）
SHOW OPEN TABLES FROM lyt WHERE In_use > 0;

-- 2. 看谁在等锁：State 里出现 Waiting for table metadata lock 就是被 MDL 挡住
SHOW PROCESSLIST;

-- 3. 表锁等待的统计（MyISAM 场景更有意义）
SHOW GLOBAL STATUS LIKE 'Table_locks%';
# Table_locks_immediate 立刻拿到锁的次数；Table_locks_waited 需要等待的次数
# waited 占比高说明表锁竞争激烈，该考虑换 InnoDB 或用行锁了

-- 4. 直接杀掉阻塞源（先从上面的视图里找到 pid，确认不是重要业务再杀）
# KILL 123;

# ============================ 表级锁踩坑清单 ============================
# 1. 加了 LOCK TABLES 之后只能访问被锁的表，碰别的表报 1100。需要的表必须一次锁全。
# 2. 别名必须和加锁时用的名字一致，否则报 1100；同一 SQL 多次引用同表要分别加锁。
# 3. READ 锁下自己也写不了（1099）；WRITE 锁下别人连读都不行。
# 4. WRITE 优先级高于 READ → 一个排队的写请求会把后面所有读请求一起堵住。
# 5. START TRANSACTION 会隐式释放表锁；要配事务请用 SET autocommit=0。
# 6. ROLLBACK 不释放表锁，回滚完还得自己 UNLOCK TABLES。
# 7. LOCK TABLES 和 UNLOCK TABLES 都会隐式提交事务，别在事务中间用。
# 8. LOCK TABLES 不能写在存储过程/函数/触发器里。
# 9. MDL 到事务结束才释放：长事务 + 一条 ALTER = 整表查询全部卡死。加字段前先查 INNODB_TRX。
# 10. 带触发器的表加表锁时，触发器用到的表会被隐式加锁，READ 还可能被升级成 WRITE。
# 11. 自动重连会悄悄丢掉表锁和事务，需要严格锁语义的程序要关掉它。
# 12. InnoDB 有行锁，日常业务基本不需要手动 LOCK TABLES；它主要留给 MyISAM 和特殊维护场景。

# ========================================================= 行级锁 =========================================================
USE lyt;

# 行级锁是 InnoDB 并发能力比 MyISAM 强的核心：
# 表锁是“我要改这张表，别人先别碰”，行锁是“我只锁命中的记录，其他行照常用”。
#
# 先记住三个总原则：
# 1. 行锁只存在于 InnoDB，MyISAM 没有行级锁。
# 2. 行锁实际上锁的是“索引记录”，不是内存里抽象的一整行。
# 3. 行锁通常到事务 COMMIT / ROLLBACK 才释放，不是 SQL 语句执行完就释放。
#    所以“更新一条记录后忘记提交”会长期挡住别人。
#
# 行锁按共享/排他分：
#   S（Shared，共享锁）     允许别的事务也加 S；别的事务要加 X 就得等
#   X（Exclusive，排他锁）  别的事务想加 S 或 X 都得等
# 同一条记录上：S+S 兼容；S+X、X+X 冲突。
# 注意“是否冲突”还要看锁定的记录/范围是否重叠：不同记录上的 X 锁可以并存。

# ============================ 一、哪些 SQL 会自动加行锁 ============================
#
# 1. 普通 SELECT：默认不加行锁
SELECT * FROM lock_row_demo WHERE id = 5;
# 它走的是 MVCC 一致性读（快照读），不需要挡住别人的 UPDATE。
# “普通 SELECT 会把整张表锁住”是错误理解。
#
# 2. UPDATE / DELETE：会自动给命中的记录加 X 锁，直到事务结束
#    UPDATE lock_row_demo SET salary = salary + 100 WHERE id = 5;
#    不需要自己写 FOR UPDATE，DML 本来就要改数据，必然需要排他锁。
#
# 3. INSERT：会给新插入的记录加 X 锁，并可能涉及插入意向锁、自增锁、唯一键检查。
#
# 4. 显式锁定读：普通 SELECT 也想加锁时，用下面两种写法
#    SELECT ... FOR SHARE   加 S 锁：允许别人也读并加 S，但不许别人改
#    SELECT ... FOR UPDATE  加 X 锁：别人想改或者也加锁读，就得等
#
# 旧写法 LOCK IN SHARE MODE 已不推荐，MySQL 8.0 用 FOR SHARE。
# FOR SHARE 不等于“只能自己一个人读”，它主要是阻止别的事务修改；
# 想让别的事务连 S 锁也不能加，要用 FOR UPDATE。
#
# autocommit=1 时，单条 FOR UPDATE 语句结束后事务也结束了，锁很快释放；
# 要观察“事务持锁期间挡住别人”，必须显式 START TRANSACTION，并保持不提交。

-- 准备行锁练习表（不碰 employee 真数据）
DROP TABLE IF EXISTS lock_row_demo;
CREATE TABLE lock_row_demo (
    id     INT PRIMARY KEY,             -- 主键天然是唯一索引，后面演示“唯一索引等值查询”
    name   VARCHAR(20) NOT NULL,
    salary DECIMAL(10, 2) DEFAULT 0
) ENGINE = InnoDB;

INSERT INTO lock_row_demo (id, name, salary)
VALUES (1, '甲', 1000.00),
       (5, '乙', 3000.00),
       (10, '丙', 8000.00);
SELECT * FROM lock_row_demo;
# 主键索引现在只有 1、5、10，后面所有区间示例都围绕这三个值。

# ============================ 二、记录锁 Record Lock ============================
#
# 记录锁：只锁某一条索引记录，不管它前后的间隙。
# 典型场景：通过“唯一索引的等值条件”精确定位唯一一行。
#
# 会话 A（保持事务不提交）：
#   START TRANSACTION;
#   SELECT * FROM lock_row_demo WHERE id = 5 FOR UPDATE;
#
# 会话 B：
#   UPDATE lock_row_demo SET salary = 4000 WHERE id = 5;   -- 被阻塞：id=5 已被 A 加 X 锁
#   UPDATE lock_row_demo SET salary = 4000 WHERE id = 1;   -- 可以执行：锁的是不同记录
#   INSERT INTO lock_row_demo VALUES (6, '丁', 5000);      -- 可以执行：唯一等值查询没有锁间隙
#
# 会话 A：
#   ROLLBACK;                                            -- 释放锁，B 被阻塞的语句才能继续
#
# data_locks 里这种“只锁记录”的模式通常带 REC_NOT_GAP：
#   X,REC_NOT_GAP  排他记录锁，不含间隙
#
# 关键：记录锁锁的是“索引记录”。
# 即使表上没有显式索引，InnoDB 也会建立隐藏的聚簇索引并用它加锁，
# 所以“没有索引就没有行锁”是错的；没有索引只是更容易扩大扫描和锁定范围。

# ============================ 三、间隙锁 Gap Lock ============================
#
# 间隙锁锁的是“索引记录之间的空隙”，目的是阻止别的事务往这个空隙里 INSERT。
# 例如当前索引值是 1、5、10，间隙包括：
#   (-∞, 1)、(1, 5)、(5, 10)、(10, +∞)
# 锁住 (1, 5) 后，插入 id=2、3、4 都会被挡住，即使这些 id 目前根本不存在。
#
# 间隙锁只防 INSERT，不是用来防止 UPDATE 已有记录；
# 更新已有记录的冲突由记录锁负责。
#
# 一个反直觉点：间隙锁的 S 和 X 不互相冲突。
# 事务 A 可以持有某间隙的 X 锁，事务 B 也能在同一间隙持有 S 锁。
# 官方称 gap lock 是“purely inhibitive”（纯粹抑制插入）：
# 它的作用只是共同声明“这段间隙不许插入”，不是 S/X 之间互相排斥。
#
# 什么时候不加间隙锁：
#   通过唯一索引等值查找唯一一行时，通常只需要记录锁。
# 什么时候还会有：
#   非唯一索引等值、范围查询、只使用联合唯一索引的一部分列等情况，都可能锁间隙。
#
# READ COMMITTED 下，搜索和索引扫描基本不使用间隙锁；
# 但外键约束检查和重复键检查仍会使用，所以不能说 RC 下“绝对没有任何间隙锁”。

# ============================ 四、临键锁 Next-Key Lock（RR 的重点） ============================
#
# 临键锁 = 记录锁 + 该索引记录“前面那段间隙”的间隙锁。
# 它不是“记录锁和间隙锁二选一”，而是两者合起来。
#
# 默认 REPEATABLE READ 下，InnoDB 做搜索/索引扫描时通常使用临键锁，
# 除了锁住查到的记录，还防止别的事务在记录前插入新值，从而解决幻读。
#
# 当前索引值 1、5、10，临键锁可能覆盖：
#   (-∞, 1]
#   (1, 5]
#   (5, 10]
#   (10, +∞)
# 左开右闭：左端点的间隙包含进来，右端点对应的索引记录也包含进来。
#
# 例：WHERE id > 5 FOR UPDATE，会锁住 (5, 10] 和 (10, +∞)：
#   id=10 这条记录本身被锁；
#   (5,10) 之间不能插入 6、7、8、9；
#   10 以后也不能插入 11、12 等（最大记录后面的间隙也被锁）。
# 但 id=4 不在这段范围内，可以插入。
#
# 两会话演示（请分别复制到两个 DataGrip 控制台，别整段全选执行）：
# 会话 A：
#   START TRANSACTION;
#   SELECT * FROM lock_row_demo WHERE id > 5 FOR UPDATE;
# 会话 B：
#   INSERT INTO lock_row_demo VALUES (7, '丁', 5000);    -- 被临键锁挡住
#   UPDATE lock_row_demo SET salary = 9000 WHERE id = 10; -- 也被记录锁挡住
#   INSERT INTO lock_row_demo VALUES (4, '丁', 5000);    -- 可以执行
# 会话 A：
#   ROLLBACK;                                            -- 释放锁
#
# 对比唯一索引等值查询：WHERE id = 5 FOR UPDATE 只锁 id=5，
# 而 WHERE id >= 5 FOR UPDATE 是范围查询，会把后面的间隙也纳入，不要混为一谈。

# ============================ 五、插入意向锁 Insert Intention Lock ============================
#
# INSERT 在真正插入前，会在目标间隙上加“插入意向锁”，然后再给新记录加 X 锁。
# 它表达的是：“我准备在这个间隙的这个位置插入”。
#
# 它的作用不是让同一个间隙里的所有 INSERT 串行：
#   事务 A 要插入 5，事务 B 要插入 6，间隙相同但位置不同，可以并发，不必互相等待。
# 但如果另一个事务已经用 Gap/Next-Key 锁把这个间隙封住，INSERT 就会等待。
#
# data_locks 里可能看到 X,INSERT_INTENTION，尤其容易在 INSERT 被间隙锁挡住时看到。

# ============================ 六、索引决定锁的范围 ============================
#
# 记住一句话：行锁沿着“执行计划实际扫描的索引”加，不是只锁 WHERE 里你想象的那一行。
#
# 1. 主键/唯一索引等值：通常只锁命中的唯一记录，范围最小。
# 2. 非唯一索引：可能有多条记录同值，还可能锁相邻间隙。
# 3. 范围条件：RR 下容易形成临键锁，锁的是一段区间。
# 4. 没有合适索引：可能全表扫描，给扫描经过的大量记录加锁，
#    虽然名字叫“行锁”，实际效果可能接近锁表。
#    RC 下不符合 WHERE 的记录锁会提前释放；RR 下范围通常更大。
#
# 二级索引也不是“只锁二级索引就完事”：
# 通过二级索引更新记录时，还会定位并锁对应的主键记录。
# 排查时看 data_locks 的 INDEX_NAME 和 LOCK_DATA，别只看 SQL 里的列名。
#
# 所以优化锁的第一步经常不是研究锁，而是：
EXPLAIN SELECT * FROM lock_row_demo WHERE id = 5;
# 看 type 是否 const/ref、key 是否真正用上索引、rows 是否很小。
# 没走索引的范围更新，先补索引，再谈锁优化。

# ============================ 七、隔离级别对行锁的影响 ============================
SHOW VARIABLES LIKE 'transaction_isolation';
# MySQL 默认 REPEATABLE READ（可重复读）。
#
# REPEATABLE READ：
#   默认用临键锁防止幻读；范围更新可能锁住较大区间；间隙锁参与较多。
# READ COMMITTED：
#   搜索/索引扫描基本不用间隙锁，一般只锁记录；
#   不符合 WHERE 的记录锁会在条件判断后释放，锁范围和持有时间都更小。
#   代价是同一个事务里两次普通 SELECT 可能看到别人已提交的新数据（不可重复读）。
#
# 临时切换当前会话做对比：
# SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
# ... 重新执行上面的范围查询演示 ...
# SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
#
# 注意：SET 只影响当前会话后续事务，不会改变已经开启的事务，
# 也不要为了测试把生产库的隔离级别随手改掉。

# ============================ 八、锁等待超时 1205 ============================
SHOW VARIABLES LIKE 'innodb_lock_wait_timeout';
# 默认通常是 50 秒：等锁超过这个时间，报
#   ERROR 1205: Lock wait timeout exceeded; try restarting transaction
#
# 1205 表示“等了很久还没拿到锁”，不一定是死锁。
# 常见原因是另一个事务没提交，或者锁的范围太大。
#
# 默认情况下，超时只回滚等待超时那条语句，不会自动回滚整个事务；
# 调用方必须决定是重试、回滚还是继续，不能把它当成“事务已经被清理干净”。

# ============================ 九、死锁 1213 ============================
#
# 死锁 = 两个事务分别拿着对方需要的锁，谁也走不下去：
#   A 已锁记录 1，想再锁记录 2；
#   B 已锁记录 2，想再锁记录 1。
# InnoDB 检测到循环等待后，自动挑一个事务回滚，另一个继续。
# 被挑中的事务收到：
#   ERROR 1213: Deadlock found when trying to get lock; try restarting transaction
#
# 经典演示（两个控制台按顺序交错执行）：
#   A: START TRANSACTION;
#   B: START TRANSACTION;
#   A: UPDATE lock_row_demo SET salary=salary+1 WHERE id=1;  -- A 拿到 1
#   B: UPDATE lock_row_demo SET salary=salary+1 WHERE id=5;  -- B 拿到 5
#   A: UPDATE lock_row_demo SET salary=salary+1 WHERE id=5;  -- A 等 B 的 5
#   B: UPDATE lock_row_demo SET salary=salary+1 WHERE id=1;  -- B 等 A 的 1 → 死锁
# 一个事务被回滚，另一个可以继续；练习结束把两个会话都 ROLLBACK。
#
# 和 1205 的区别：
#   1205 锁等待超时：排队太久，可能根本没形成死锁
#   1213 死锁：检测到循环等待，主动回滚一个事务来解开

-- 查看最近一次死锁详情：重点看 LATEST DETECTED DEADLOCK 段
SHOW ENGINE INNODB STATUS;
# DataGrip 控制台一般直接执行 SHOW ENGINE INNODB STATUS; 也可以：
SHOW ENGINE INNODB STATUS;
# 里面能看到两个事务各自在执行什么 SQL、拿着什么锁、在等什么锁，
# 以及最后哪个事务被回滚（WE ROLL BACK TRANSACTION ...）。

# ============================ 十、NOWAIT 与 SKIP LOCKED ============================
#
# 不想排队时，可以在锁定读后面加：
#   FOR UPDATE NOWAIT      拿不到锁就立刻报错，不等
#   FOR UPDATE SKIP LOCKED 跳过被别的事务锁住的记录，只返回能锁到的
#   FOR SHARE NOWAIT / FOR SHARE SKIP LOCKED 同样适用
#
# 例子：
#   SELECT * FROM lock_row_demo WHERE id > 0 FOR UPDATE NOWAIT;
#   SELECT * FROM lock_row_demo WHERE id > 0 FOR UPDATE SKIP LOCKED;
#
# NOWAIT 适合“锁不住就快速失败”的业务；
# SKIP LOCKED 适合多消费者抢任务队列：每个人跳过别人正在处理的任务。
# 注意：SKIP LOCKED 得到的是不完整的视图，不适合要求精确统计总数的查询。

# ============================ 十一、查看行锁与等待 ============================
-- 1. 看 InnoDB 当前持有的行锁/表锁
SELECT ENGINE, ENGINE_LOCK_ID, ENGINE_TRANSACTION_ID,
       OBJECT_SCHEMA, OBJECT_NAME, INDEX_NAME,
       LOCK_TYPE, LOCK_MODE, LOCK_STATUS, LOCK_DATA
FROM performance_schema.data_locks
WHERE OBJECT_SCHEMA = 'lyt';
# LOCK_TYPE=RECORD 表示索引记录锁
# LOCK_MODE：
#   S / X                 共享/排他，可能包含间隙
#   S,REC_NOT_GAP         只锁记录
#   X,REC_NOT_GAP         只锁记录
#   S,GAP / X,GAP         只锁间隙
#   X,INSERT_INTENTION    插入意向锁
# LOCK_DATA：记录对应的索引值；出现 supremum 表示最大索引值之后的伪记录/间隙。
# 没有活跃事务持锁时，这张表是空的，不是 SQL 写错了。

-- 2. 看谁等谁
SELECT * FROM performance_schema.data_lock_waits;
# REQUESTING_ENGINE_TRANSACTION_ID 是等待锁的事务
# BLOCKING_ENGINE_TRANSACTION_ID 是持锁、挡住别人前进的事务

-- 3. 看事务开了多久、最后一条 SQL 是什么
SELECT trx_id, trx_state, trx_started,
       TIMESTAMPDIFF(SECOND, trx_started, NOW()) AS `事务已运行秒数`,
       trx_mysql_thread_id
FROM information_schema.INNODB_TRX
ORDER BY trx_started;

-- 4. 看线程/连接，准备定位阻塞源
SELECT PROCESSLIST_ID, PROCESSLIST_USER, PROCESSLIST_HOST,
       PROCESSLIST_DB, PROCESSLIST_COMMAND, PROCESSLIST_TIME, PROCESSLIST_INFO
FROM performance_schema.threads
WHERE PROCESSLIST_ID IS NOT NULL;

# 找到阻塞源之后，优先联系对应会话正常 COMMIT/ROLLBACK；
# 确认可以终止时才 KILL <processlist_id>，不要看到锁就乱杀业务事务。

-- 收尾：练习完清理表
DROP TABLE IF EXISTS lock_row_demo;

# ============================ 行级锁踩坑清单 ============================
# 1. 普通 SELECT 默认走 MVCC 快照读，不加行锁；要加锁必须显式 FOR SHARE / FOR UPDATE。
# 2. UPDATE/DELETE 会自动加 X 锁；不要以为没写 FOR UPDATE 就没有锁。
# 3. 行锁通常到事务结束才释放。长事务、忘提交，是别人卡住的头号原因。
# 4. 行锁锁的是索引记录，不是“表里抽象的一行”；没有显式索引也会用隐藏聚簇索引。
# 5. 唯一索引等值查询通常只加记录锁；非唯一索引、范围查询可能加间隙锁/临键锁。
# 6. 临键锁 = 记录锁 + 前面的间隙，默认 RR 用来防幻读；左开右闭，别只盯查到的那一行。
# 7. 间隙锁只阻止 INSERT，且 S/X 间隙锁之间不冲突，不要套用记录锁的 S+X 互斥理解。
# 8. RC 基本取消搜索/扫描的间隙锁，但外键和重复键检查仍会用；别说成“RC 完全没有间隙锁”。
# 9. 没走索引可能扫描并锁住大量记录，看起来像锁表。先用 EXPLAIN 看扫描范围。
# 10. 1205 是锁等待超时，1213 是死锁；前者等太久，后者被 InnoDB 主动回滚一个事务。
# 11. 1205 默认只回滚超时语句，不等于整个事务已经回滚；应用程序必须处理后续事务状态。
# 12. NOWAIT 是拿不到锁立刻报错，SKIP LOCKED 是跳过被锁记录；后者结果可能不完整，别拿去精确计数。

# ================================================== InnoDB 事务原理 与 MVCC ==================================================
USE lyt;

# 对应课程 81~90：
#   81 事务原理概述   82 redo log        83 undo log
#   84 MVCC 基本概念  85 隐藏字段        86 undo log 版本链
#   87 ReadView      88 RC 原理分析     89 RR 原理分析      90 小结
#
# 一句话先串起来：
#   redo log 保证“改了的东西丢不了”（持久性）
#   undo log 保证“改错了能退回去”（原子性），同时提供旧版本给 MVCC 读
#   MVCC 用“版本链 + ReadView”让读不加锁也能读到一致的数据（隔离性）
#   一致性是最终目的，靠上面三个 + 锁共同实现

# ============================ 81. 事务原理概述 ============================
#
# ACID 四个特性，以及 InnoDB 分别靠什么落地：
#
#   特性      含义                          实现手段
#   --------  ----------------------------  ----------------------------------------
#   原子性 A  事务里的操作要么全成要么全败   undo log（记录反向操作，回滚时执行）
#   一致性 C  数据从一个合法状态到另一个    最终目的，靠 A/I/D + 业务约束共同保证
#   隔离性 I  并发事务之间互不干扰          锁（当前读）+ MVCC（快照读）
#   持久性 D  提交了就不会丢                 redo log（WAL：先写日志，后刷数据页）
#
# 核心设计思想：WAL（Write-Ahead Logging，日志先行）
#   修改数据时不是直接把数据页写回磁盘，而是：
#     1. 先把“改了什么”顺序写入 redo log（顺序 IO，快）
#     2. 数据页（脏页）留给后台线程慢慢刷盘（随机 IO，慢）
#   这样事务提交只需要保证 redo log 落盘，就算此刻宕机，重启后也能用 redo 重放出来。
#   好处：把随机写变成顺序写，事务提交的响应时间大幅缩短。
#
# 一个重要区分（面试常问）：
#   redo log 是 InnoDB 存储引擎层的物理日志，循环写，用于崩溃恢复
#   binlog   是 MySQL Server 层的逻辑日志，追加写，用于主从复制和数据归档
#   两者靠“两阶段提交”保证一致：redo prepare → 写 binlog → redo commit
#   崩溃恢复时：redo 处于 prepare 且 binlog 完整 → 提交；否则回滚

# ============================ 82. redo log ============================
#
# 是什么：物理日志，记录“在哪个数据页的哪个位置、做了什么修改”。
#         注意它是“物理到页、逻辑到页内”，不是记录整行数据，也不是记录 SQL 语句。
#
# 解决什么问题：事务提交后，脏页还没刷到磁盘时宕机，数据就丢了。
#               有了 redo，只要日志在，就能重放恢复。
#
# 结构：由 ib_logfile0、ib_logfile1 ... 组成（innodb_log_files_in_group 控制个数），
#       是一个“固定大小、循环写”的环形空间：
#
#        write pos ──►  ┌──────── 可写区域 ────────┐
#                       └──────────────────────────┘
#        checkpoint ──► 已被 checkpoint 覆盖、可复用的区域
#
#   write pos：当前写到哪了
#   checkpoint：哪些日志对应的脏页已经刷盘、日志可以复用
#   两者之间就是“还没刷盘但日志已写”的部分
#   如果 write pos 追上 checkpoint（环形写满）→ 必须先推进 checkpoint，也就是强制刷脏页，
#   这时会出现明显的写入卡顿。所以 redo 太小会拖慢写入，太大会增加崩溃恢复时间。
#
# 刷盘时机由 innodb_flush_log_at_trx_commit 控制：
#   0  每秒把 log buffer 写 OS cache 并 fsync 一次 → 可能丢最近 1 秒事务，性能最好
#   1  每次提交都 fsync（默认）→ 不丢事务，最安全，但每次提交都要等磁盘
#   2  每次提交写 OS cache，每秒 fsync → 数据库崩溃不丢，操作系统崩溃可能丢 1 秒
SHOW VARIABLES LIKE 'innodb_flush_log_at_trx_commit';

-- 看 redo 的容量和文件数
SHOW VARIABLES LIKE 'innodb_log_file_size';
SHOW VARIABLES LIKE 'innodb_log_files_in_group';
# 总容量 = innodb_log_file_size × innodb_log_files_in_group

-- 看 redo 的实时位置（LOG 段里的 Log sequence number / checkpoint）
SHOW ENGINE INNODB STATUS;
# 重点看这几行：
#   Log sequence number       当前 LSN
#   Log flushed up to         已刷到磁盘的 LSN
#   Last checkpoint at        checkpoint LSN
# LSN 是单调递增的日志序号，不是文件偏移；三者差距越大，说明待刷脏页越多。

# ============================ 83. undo log ============================
#
# 是什么：逻辑日志，记录“反向操作”，不是数据页的物理备份。
#   INSERT  → undo 里记一条 DELETE
#   DELETE  → undo 里记一条 INSERT（把整行旧值存下来）
#   UPDATE  → undo 里记一条反向 UPDATE（把旧值写回）
#
# 两个作用，缺一不可：
#   1. 回滚（原子性）：事务 ROLLBACK 或崩溃恢复时，按 undo 逆序执行反向操作
#   2. 多版本（MVCC）：给快照读提供历史版本，读到“这个事务开始之前的样子”
#
# 分类：
#   insert undo log  只有本事务自己能看见，提交后立刻可以删除（别人不需要这个版本）
#   update undo log  UPDATE/DELETE 产生，必须留着给 MVCC 用，不能提交就删
#                    → 由后台 purge 线程判断“没有任何 ReadView 还需要它”时才清理
#
# 存在哪：undo 表空间（8.0 默认独立 undo tablespace，如 undo_001、undo_002）
#         旧版本在 rollback segment 里，段内分 undo slot / undo log segment

-- 看 undo 表空间
SELECT SPACE, NAME, FILE_SIZE, STATE FROM information_schema.INNODB_TABLESPACES
WHERE NAME LIKE 'undo%';

-- 看历史版本链长度（HISTORY LIST LENGTH）
SHOW ENGINE INNODB STATUS;
# HISTORY LIST LENGTH = 还没被 purge 的 update undo log 数量
# 这个值持续上涨通常意味着：有长事务一直不提交，或者有慢查询的 ReadView 一直开着
# 后果：undo 表空间膨胀、回滚变慢、甚至把磁盘撑满 —— 长事务的真正代价在这里

# ============================ 84. MVCC 基本概念 ============================
#
# MVCC = Multi-Version Concurrency Control，多版本并发控制。
# 目标：读写互相不阻塞。读的时候不加锁，也能读到“某个时刻一致的数据快照”。
#
# 两种读，必须分清：
#
#   快照读（Snapshot Read / 一致性读）
#     - 普通 SELECT，不加任何锁
#     - 读的是 undo log 版本链上的历史版本，走 MVCC
#     - 例：SELECT * FROM employee WHERE id = 1;
#
#   当前读（Current Read）
#     - 读的是最新已提交版本，并且要加锁
#     - 例：SELECT ... FOR UPDATE / FOR SHARE、UPDATE、DELETE、INSERT
#     - 走的是锁（记录锁/间隙锁/临键锁），不走 MVCC 的可见性判断
#
# 结论：MVCC 只解决“快照读”的并发问题，当前读还是得靠锁。
# 这也解释了上一节的疑惑：为什么普通 SELECT 不加锁却不会读到脏数据 —— 因为它读的是历史版本。

# ============================ 85. 隐藏字段 ============================
#
# InnoDB 的聚簇索引记录里，除了你定义的列，还有几个看不见的系统列：
#
#   DB_TRX_ID    6 字节   最近一次插入或修改这一行的事务 ID
#   DB_ROLL_PTR  7 字节   回滚指针，指向 undo log 中这一行的上一个版本
#   DB_ROW_ID    6 字节   隐藏行 ID，仅当表没有主键、也没有唯一非空索引时才生成
#                         （此时 InnoDB 用它建隐藏聚簇索引）
#
# 记忆方式：
#   DB_TRX_ID   → “这行是谁改的”，MVCC 可见性判断就看它
#   DB_ROLL_PTR → “上一个版本在哪”，沿它走版本链
#   DB_ROW_ID   → “没有主键时的替代主键”
#
# 除了这三个，行记录头里还有 delete_flag（删除标记位）：
#   DELETE 语句在 MVCC 里不是物理删除，而是打上删除标记，
#   真正的物理清除由 purge 线程完成。所以快照读能看到“已删除”的历史版本。
#
# 这些都是 InnoDB 内部的物理结构，SQL 层查不到；
# 想看只能借助工具解析 ibd 文件（如 innodb_ruby / innodb_parser），日常靠原理理解即可。

# ============================ 86. undo log 版本链 ============================
#
# 每修改一次，旧版本就被写进 undo log，并用 DB_ROLL_PTR 串起来，
# 形成一条从“最新版本”向“最老版本”走的单链表：
#
#   聚簇索引记录（最新）
#     │ DB_TRX_ID = 30, DB_ROLL_PTR ──┐
#     ▼                              │
#   undo log：旧版本（trx 20）        │
#     │ DB_ROLL_PTR ─────────────────┘
#     ▼
#   undo log：旧版本（trx 10）
#     │ DB_ROLL_PTR
#     ▼
#   undo log：更早的版本 ...
#
# 访问一行数据时：
#   1. 先看最新版本的 DB_TRX_ID，按 ReadView 判断“我能不能看”
#   2. 不能看就顺着 DB_ROLL_PTR 找上一个版本，再判断
#   3. 一直往前找，直到找到一个“对我可见”的版本，或者链走完（说明这行对我不可见）
#
# 这就是“可重复读”的底层机制：不是把数据复制一份给你，
# 而是通过版本链 + 可见性规则，让你看到属于你那个时刻的版本。

-- 准备 MVCC 演示表
DROP TABLE IF EXISTS mvcc_demo;
CREATE TABLE mvcc_demo (
    id     INT PRIMARY KEY,
    name   VARCHAR(20) NOT NULL,
    salary DECIMAL(10, 2) DEFAULT 0
) ENGINE = InnoDB;

INSERT INTO mvcc_demo (id, name, salary)
VALUES (1, '甲', 1000.00),
       (2, '乙', 2000.00);
SELECT * FROM mvcc_demo;

# ============================ 87. ReadView ============================
#
# ReadView 是“快照读的可见性判断依据”，可以理解成：生成快照那一刻，
# 数据库给当前事务拍了一张“此时哪些事务还活着”的照片。
#
# 四个核心字段：
#
#   m_ids          生成 ReadView 时，所有“已启动但未提交”的事务 ID 列表
#   min_trx_id     m_ids 中的最小值（活跃事务里最小的那个）
#   max_trx_id     生成 ReadView 时，下一个将要分配的事务 ID
#                  （注意：不是 m_ids 的最大值；有些资料写“最大值+1”，那是近似说法）
#   creator_trx_id 创建这个 ReadView 的事务 ID（也就是“我自己”）
#
# 可见性判断算法（拿记录的 DB_TRX_ID 去比）：
#
#   ① trx_id == creator_trx_id       → 可见（是我自己改的，当然能看见）
#   ② trx_id <  min_trx_id           → 可见（这个事务在我生成快照前就提交了）
#   ③ trx_id >= max_trx_id           → 不可见（这个事务在我生成快照之后才启动）
#   ④ min_trx_id <= trx_id < max_trx_id：
#        trx_id 在 m_ids 里     → 不可见（它当时还活跃，没提交）
#        trx_id 不在 m_ids 里   → 可见（它当时已经提交了）
#
#   判断为“不可见” → 顺着 DB_ROLL_PTR 找上一个版本，重复上面四步。
#
# 为什么 ③ 用 >= 而不是 >：
#   事务 ID 是按启动顺序递增分配的，max_trx_id 是“下一个待分配”的值，
#   等于 max_trx_id 的事务还没出生，对当前 ReadView 一定不可见。

# ============================ 88. RC 级别原理分析 ============================
#
# READ COMMITTED 的核心：**每次快照读都重新生成一个 ReadView**。
#
# 于是：别人提交了，我下一次 SELECT 就能看到 → 出现“不可重复读”。
#
# 两会话演示（分别复制到两个控制台，别整段全选执行）：
#
# 会话 A：
#   SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
#   START TRANSACTION;
#   SELECT * FROM mvcc_demo WHERE id = 1;        -- 第一次读：salary = 1000
#
# 会话 B：
#   START TRANSACTION;
#   UPDATE mvcc_demo SET salary = 1500 WHERE id = 1;
#   COMMIT;
#
# 会话 A：
#   SELECT * FROM mvcc_demo WHERE id = 1;        -- 第二次读：salary = 1500 ！
#   -- 同一个事务内两次读结果不同 → 不可重复读
#   COMMIT;
#
# 原理：第一次 SELECT 用的 ReadView 里，B 还没提交；
#       第二次 SELECT 重新生成 ReadView，B 已提交，所以可见。
#
# 顺带：RC 下幻读也更明显（同一事务两次范围查询，行数可能变化），
#      因为 RC 基本不加间隙锁，也没有稳定的快照。

# ============================ 89. RR 级别原理分析 ============================
#
# REPEATABLE READ 的核心：**只在事务中第一次快照读时生成 ReadView，之后整个事务复用这一个**。
#
# 于是：别人在事务期间提交了，我依然看不到 → 可重复读。
#
# 两会话演示：
#
# 会话 A：
#   SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
#   START TRANSACTION;
#   SELECT * FROM mvcc_demo WHERE id = 1;        -- 第一次读：salary = 1500（举例）
#                                                -- 此刻生成 ReadView，之后一直用它
#
# 会话 B：
#   START TRANSACTION;
#   UPDATE mvcc_demo SET salary = 9999 WHERE id = 1;
#   COMMIT;
#
# 会话 A：
#   SELECT * FROM mvcc_demo WHERE id = 1;        -- 再读：还是 1500，看不到 B 的修改
#   COMMIT;
#
# 原理：ReadView 不重新生成，B 的事务 ID 不在我的可见范围里，
#       所以即使 B 已提交，我也只能沿着版本链读到旧版本。
#
# 但注意两个"例外"，很多人在这里答错：
#
# 1. 当前读不受这个快照限制
#      SELECT * FROM mvcc_demo WHERE id = 1 FOR UPDATE;   -- 读最新值 9999，并加锁
#    RR 的“可重复读”只保证快照读，当前读永远读最新已提交数据。
#
# 2. RR 能防幻读，靠的不只是 MVCC
#    快照读靠 ReadView 让新插入的行不可见；
#    当前读（FOR UPDATE / UPDATE 范围）靠 Next-Key Lock 锁住间隙，阻止别人插入。
#    只靠 MVCC 防不住当前读场景下的幻读。

-- 确认当前隔离级别
SELECT @@transaction_isolation;
SHOW VARIABLES LIKE 'transaction_isolation';
# 默认 REPEATABLE-READ

# ============================ 90. 小结 ============================
#
# 一张表收尾：
#
#   组件        层次          类型        解决的问题              关键点
#   ----------  ------------  ----------  ----------------------  ----------------------------
#   redo log    InnoDB 引擎   物理日志    持久性 / 崩溃恢复       循环写；WAL；LSN；checkpoint
#   undo log    InnoDB 引擎   逻辑日志    原子性回滚 + MVCC 版本  insert undo 可早删；update undo 留给 MVCC
#   MVCC        InnoDB 机制   ——          读写不阻塞的隔离性      版本链 + ReadView
#   锁          InnoDB 机制   ——          当前读的隔离性          记录锁/间隙锁/临键锁
#
# 三句话记住本质：
#   1. redo 让“已提交的不丢”，undo 让“没提交的能退”，MVCC 让“读不用等写”。
#   2. RC 和 RR 的差别只有一个：ReadView 是每次都新建，还是事务内只建一次。
#   3. 快照读走 MVCC，当前读走锁；RR 的“可重复读”只对快照读成立。
#
# 面试高频追问，先备着：
#   Q: 为什么 RC 会出现不可重复读？     A: 每次 SELECT 新建 ReadView，能看到新提交的事务。
#   Q: RR 怎么解决幻读？                A: 快照读靠 ReadView 复用；当前读靠 Next-Key Lock 锁间隙。
#   Q: 长事务的危害？                   A: undo 不能 purge → 版本链变长、undo 表空间膨胀、回滚慢、
#                                          HISTORY LIST LENGTH 上涨，还可能拖住 MDL 导致 DDL 卡死。
#   Q: redo 和 binlog 的区别？          A: redo 是引擎层物理日志、循环写、管崩溃恢复；
#                                         binlog 是 Server 层逻辑日志、追加写、管复制与归档；靠两阶段提交对齐。
#   Q: 为什么 redo 能提升性能？          A: 顺序 IO 替代随机 IO，提交只保证日志落盘，脏页异步刷。

-- 收尾：练习完清理
DROP TABLE IF EXISTS mvcc_demo;

# ============================ 事务与 MVCC 踩坑清单 ============================
# 1. 普通 SELECT 是快照读，不加锁；以为它加锁会导致对锁行为判断错误。
# 2. RR 的“可重复读”只管快照读，FOR UPDATE / UPDATE 这类当前读永远读最新数据。
# 3. RC 每次 SELECT 新建 ReadView，所以同一事务两次查询可能不一致，业务逻辑别依赖它。
# 4. ReadView 只在第一次快照读时生成（RR），所以事务里“第一条 SELECT 的时机”决定你看到的世界。
# 5. 长事务是 undo 膨胀的根源：版本链越来越长，purge 无法清理，磁盘和性能一起告急。
# 6. 大事务回滚极慢，因为要顺着 undo 逆序执行；线上尽量拆小。
# 7. innodb_flush_log_at_trx_commit=0/2 会牺牲持久性换性能，金融类业务别改。
# 8. redo log 太小会导致频繁 checkpoint 刷脏页，写入出现周期性抖动，表现为“每隔一会儿卡一下”。
# 9. delete 不是立即物理删除，而是打标记；表空间不会马上变小，需要 OPTIMIZE TABLE 或重建表回收。
# 10. 别用 SELECT * 做超大范围快照读：会长时间持有 ReadView，间接拖住 purge。
