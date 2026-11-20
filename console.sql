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
