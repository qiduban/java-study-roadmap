# show databases ;
# use lyt;
# show tables ;
# desc lyt.表名;
# # # alter table 表名 change column 数据2 数据 varchar(255);
# # desc 表名;
# # ALTER TABLE 表名 DROP PRIMARY KEY;
# # alter table 表名 CHANGE COLUMN 主键 主键 INT;
# # DESC 表名;
# # ALTER TABLE 表名 DROP PRIMARY KEY;
# # DESC 表名;
# # alter table 表名 add primary key (主键);
# # alter table 表名 modify column 主键 int auto_increment;
# # desc 表名;
# SHOW DATABASES;
# USE wms;
# show tables;
# use wms;
# DESC girfirend;
# #添加外键是要注意，参照表下的参照列必须是不可重复的，换言之必须为主键或者是唯一键
# ALTER TABLE lyt.boyfirend ADD PRIMARY KEY (person_id);
# # fk_*******_*****为自定义的外键名
# ALTER TABLE girfirend ADD CONSTRAINT fk_girfirend_boyfirend FOREIGN KEY (person_id) references lyt.boyfirend(person_id);
# # ALTER TABLE girfirend DROP FOREIGN KEY fk_girfirend_boyfirend;通过外键的名字来删除外键
# ALTER TABLE girfirend DROP FOREIGN KEY fk_girfirend_boyfirend;
# desc girfirend;
# SHOW CREATE TABLE girfirend;
# #添加唯一约束
# # uk_person_id同样为约束名，删除也是通过删除约束名来删除
# ALTER TABLE girfirend ADD CONSTRAINT uk_person_id UNIQUE (person_id);
# SHOW CREATE TABLE girfirend;
# ALTER TABLE girfirend DROP KEY uk_person_id;
# SHOW CREATE TABLE girfirend;
# #添加非空约束ALTER TABLE 表名 MODIFY 列名 类型 NOT NULL;
# ALTER TABLE girfirend MODIFY person_id INT NOT NULL ;
# SHOW CREATE TABLE girfirend;
# #删除非空约束并不是通过删除约束名而是通过modify更改约束类型
# ALTER TABLE girfirend MODIFY person_id INT NULL;
# SHOW CREATE TABLE girfirend;
# SHOW KEYS FROM girfirend;
#创建表时添加主键
#注意：这个 demo 在第 97 行还会重建一次；IDEA 只按文件里第一处 CREATE 解析，两处列定义必须一致，否则后面所有 demo.name / demo.address 都会爆红
CREATE TABLE demo(
  id INT PRIMARY KEY,
  name VARCHAR(255),
  address VARCHAR(255) DEFAULT 'Unknow'
);
#创建表时添加非空约束
CREATE TABLE demo1(
    id INT NOT NULL
);
#创建表时添加唯一约束
CREATE TABLE demo2(
    id INT,
    receiver int not null,
    CONSTRAINT uk_id UNIQUE (id)
);
#创建表时添加外部约束
CREATE TABLE demo3(
    id INT,
    CONSTRAINT fk_demo1_demo FOREIGN KEY (id) REFERENCES demo(id)
);
SHOW KEYS FROM demo;
SHOW KEYS FROM demo2;
SHOW KEYS FROM demo3;
#删除主键约束(建表时 PRIMARY KEY 加的主键)
ALTER TABLE demo DROP PRIMARY KEY;
#删除唯一约束(按约束名删除,建表时约束名为 uk_id)
ALTER TABLE demo2 DROP KEY uk_id;
#删除外键约束(按外键名删除,建表时外键名为 fk_demo1_demo)
ALTER TABLE demo3 DROP FOREIGN KEY fk_demo1_demo;
#删除非空约束(没有约束名,用 MODIFY 改回可空)
ALTER TABLE demo1 MODIFY id INT NULL;
#查看结果
#SHOW CREATE TABLE 为查看完整的建表语句
SHOW CREATE TABLE demo;
SHOW CREATE TABLE demo1;
SHOW CREATE TABLE demo2;
SHOW CREATE TABLE demo3;
SHOW KEYS FROM demo;
DROP TABLE demo, demo1, demo2, demo3;
USE lyt;
#设置主键并将主键数据类型改为自动增长型
show tables ;
ALTER TABLE boyfirend ADD PRIMARY KEY (person_id);
ALTER TABLE boyfirend MODIFY COLUMN person_id INT AUTO_INCREMENT;
#姓名词条改为非空
ALTER TABLE boyfirend MODIFY COLUMN person_name VARCHAR(10) NOT NULL;
#选择插入数据
INSERT INTO boyfirend(person_id, person_name) VALUES (1, '王梦燊');
SHOW CREATE TABLE boyfirend;
INSERT INTO boyfirend(person_name) VALUES ('WMS');
#完全插入 主键自动增长类型可以用“0,NULLn或default”占位
INSERT INTO boyfirend VALUES (0,'WMS',123456);
ALTER TABLE boyfirend MODIFY COLUMN person_name VARCHAR(255);
#通过default设置默认值来实现为输出值时表中自动填充默认值
CREATE TABLE demo (id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    address VARCHAR(255) DEFAULT 'Unknow'
);
INSERT INTO demo VALUES (DEFAULT,'114514',DEFAULT);
#UPDATE表名 SET 列名 = 值 列名 = 值 WHERE 条件;
#更新语句中一定要给定更新条件，否则表中的所有数据都会被更新
UPDATE DEMO SET address = '江苏省苏州市工业园区星湖街' WHERE address = 'Unknow';
# demo (name, address) VALUES
# ('苗婷杰', '湖北省武汉市江汉区创业路100号14栋2535室'),
# ('李明静', '北京市海淀区解放路256号20栋629室'),
# ('韩倩琳', '陕西省西安市碑林区人民路143号22栋1019室'),
# ('沈文宇', '四川省成都市青羊区创业路821号30栋2522室'),
# ('彭凯楠', '山东省济南市天桥区和平路944号24栋1354室'),
# ('赵艳鑫', '辽宁省沈阳市沈河区解放路617号21栋289室'),
# ('俞倩静', '山东省济南市历城区花园街145号17栋204室'),
# ('谢芳鑫', '广东省深圳市罗湖区黄河路881号30栋1049室'),
# ('孙凯静', '江苏省南京市鼓楼区黄河路302号5栋2151室'),
# ('贺婷艳', '福建省厦门市同安区科技路414号26栋693室');
# SELECT COUNT(*) AS total_rows FROM demo; SELECT * FROM demo ORDER BY id;"
# DELETE删除数据
# DELETE FROM 表名 WHERE 条件;
# 注意在DELETE语句中，如果没有给定删除条件则会删除表中的所有数据。
DELETE FROM demo WHERE name = '114514';
DESC demo;
SHOW CREATE TABLE demo;
UPDATE demo SET id = id - 11 WHERE id > 10;
#TRUNCATE清空表;
TRUNCATE TABLE DEMO;
# DELETE：可以挑着删，也可以全部删。
# TRUNCATE：整张表清空，不能挑着删。
# DROP：连表结构一起删除。

# SELECT * | {[DISTINCT] column | expression [alias], ...} FROM table;
# SELECT语句从数据库中返回信息。使用一个SELECT语句，可以做下面的事:
# 列选择:能够使用SELECT语句的列选择功能选择表中的列，这些列是想要用查询返回的。当查询时，能够返回列中的数据。
# 行选择:能够使用SELECT语句的行选择功能选择表中的行，这些行是想要用查询返回的。能够使用不同的标准限制看见的行。
# 连接:能够使用SELECT语句的连接功能来集合数据，这些数据被存储在不同的表中，在它们之间可以创建连接，查询出我们所关心的数据。
# SELECT 确定哪些表 FROM 确定哪些表
-- SELECT：指定要查询的字段列表
-- DISTINCT：去除查询结果中的重复行
-- column：字段名
-- expression：表达式
-- *：选择所有列
-- AS alias：给查询字段设置别名
-- FROM：指定查询的表
-- WHERE：筛选满足条件的记录
-- GROUP BY：按照指定字段分组
-- HAVING：筛选分组后的结果
-- ORDER BY：对查询结果排序
-- ASC：升序（默认）
-- DESC：降序
-- LIMIT：限制返回的记录数量
-- offset：偏移量，从 0 开始
-- row_count：返回的记录数量
USE lyt;
DESC DEMO;
DESC demo;
# desc demo3;  # demo3 已在第 78 行被 DROP，表不存在
SELECT * FROM demo;
# SELECT receiver FROM demo2 WHERE receiver = '姜明';  # demo2 已在第 78 行被 DROP，表不存在
USE lyt;
SHOW TABLES;
DESC demo;
SHOW CREATE TABLE demo;
USE wms;
CREATE TABLE friend(
    name VARCHAR(255) primary key,
    height DOUBLE not null ,
    weight DOUBLE not null ,
    address VARCHAR(255) DEFAULT 'Unknow'
);
DESC friend;
USE wms;
SHOW TABLES ;
INSERT INTO friend VALUES ('祁雷',1.78,138,DEFAULT);
UPDATE friend SET height = 1.85 WHERE name = '祁雷';
DROP TABLE friend;
SELECT demo.id,
       demo.name,
       demo.address,
       demo.id * 10
FROM demo;
SELECT  * FROM demo;
#如果一行中的某列缺少一个数据值，该值被置为null，或者是包含一个空

#SELECT 别名 AS 列别名 FRIM 表名 WHERE 条件；
#注意：别名只改变查询结果的显示名称，不会修改表中真实的字段名。
SELECT demo.name AS 姓名 FROM demo;
#去除像同行：
#           SELECT DISTINCT 列名 FROM 表名
INSERT INTO DEMO VALUES (26,'吕峰','辽宁省沈阳市和平区光明街835号23栋993室');
UPDATE demo SET address = '辽宁省沈阳市和平区光明街835号23栋943室' WHERE id = 26;
SELECT DISTINCT demo.name FROM demo;
SELECT name FROM demo;
#distinct 是对结果集进行去重不是对某一列去重，像下列代码，即使name重复只要address不重复测不会被去重
SELECT DISTINCT name , address from demo;
#SELECT 的行限制 SELECT * | 投影列 FROM 表名 WHERE 选择条件；
SELECT name FROM demo LIMIT 10;
#限制只查询五条数据


# -- ==================== MySQL 比较条件 ====================
#
# -- 1. 等于
# WHERE age = 18;
#
# -- 2. 不等于（两种写法）
# WHERE age != 18;
# WHERE age <> 18;
#
# -- 3. 大于
# WHERE age > 18;
#
# -- 4. 小于
# WHERE age < 18;
#
# -- 5. 大于等于
# WHERE age >= 18;
#
# -- 6. 小于等于
# WHERE age <= 18;
#
# -- 7. 在指定范围内（包含边界值）
# WHERE age BETWEEN 18 AND 30;
#
# -- 8. 不在指定范围内
# WHERE age NOT BETWEEN 18 AND 30;
#
# -- 9. 在指定集合中
# WHERE age IN (18, 20, 25);
#
# -- 10. 不在指定集合中
# WHERE age NOT IN (18, 20, 25);
#
# -- 11. 模糊匹配：以“张”开头
# WHERE name LIKE '张%';
#
# -- 12. 模糊匹配：以“张”结尾
# WHERE name LIKE '%张';
#
# -- 13. 模糊匹配：包含“张”
# WHERE name LIKE '%张%';
#
# -- 14. 模糊匹配：第二个字符是“张”
# WHERE name LIKE '_张%';
#
# 模糊查询的通配符，作用不一样：
# ‘%’：匹配 0 个、1 个或多个任意字符。
# ‘_’：匹配 恰好 1 个任意字符。
# -- 15. 判断为 NULL
# WHERE age IS NULL;
#
# -- 16. 判断不为 NULL
# WHERE age IS NOT NULL;
#
# -- 17. NULL 安全等于（NULL 与 NULL 比较也返回真）
# WHERE a <=> b;
#
# -- ==================== 结束 ====================
#BETWEEN条件的使用,SELECT 列名 FROM 表名 WHERE 限制列名 BETWEEN 下限 AND 上限
USE lyt;
SELECT demo.name FROM demo WHERE id BETWEEN 3 AND 15;
INSERT INTO demo(id,name)  values(27,'wmf');
#select is null / is not null 的用法
SELECT demo.address FROM demo WHERE address is null;
#使用逻辑条件 and or not where
SELECT employee.name, salary FROM employee WHERE salary > 8000 AND name LIKE '%e%';
#查询employees表中雇员薪水大于8000的并且名字中含有e的雇员名字与薪水。
SELECT employee.name, salary FROM employee WHERE salary < 8000 OR name LIKE '%e%';
#查询employees表中雇员薪水小于8000的或者名字中含有e的雇员名字与薪水。
SELECT employee.name, salary FROM employee WHERE name NOT LIKE '%e%';
#查询名字中不含有字母‘e’的员工姓名和薪水
# ————————————————++++优先级++++——————————————————————
#            () 括号 > NOT > AND > OR。
# SELECT语句的执行顺序如下:
# FROM子句
# WHERE子句
# SELECT子句
# ORDERBY子句

#ORDER BY 排序默认为升序，且排序必须写在查询语句的最后
SELECT * FROM employee ORDER BY salary;
#DESC为降序 ASC为升序
SELECT * FROM employee ORDER BY age DESC ,salary ASC;
SELECT age, COUNT(age) AS 人数 FROM employee WHERE salary > 20000 AND age <40 GROUP BY employee.age HAVING COUNT(salary) > 1;

#-------------------------------------例题-----------------------------------------
# 表: Person
# +-------------+---------+
# | Column Name | Type    |
# +-------------+---------+
# | id          | int     |
# | email       | varchar |
# +-------------+---------+
# id 是该表的主键（具有唯一值的列）。
# 此表的每一行都包含一封电子邮件。电子邮件不包含大写字母。
# 编写解决方案来报告所有重复的电子邮件。 请注意，可以保证电子邮件字段不为 NULL。
# 以 任意顺序 返回结果表。
# 结果格式如下例。
# 示例 1:
# 输入:
# Person 表:
# +----+---------+
# | id | email   |
# +----+---------+
# | 1  | a@b.com |
# | 2  | c@d.com |
# | 3  | a@b.com |
# +----+---------+
# 输出:
# +---------+
# | Email   |
# +---------+
# | a@b.com |
# +---------+
# 解释: a@b.com 出现了两次。
# -------------------------------------------解答----------------------------------------------------
#                                           SELECT email AS Email
#                                           FROM Person
#                                           GROUP BY email
#                                           HAVING COUNT(*) > 1;
#                                           为什么要分组：
#                                           分组会把数据整合在一起不然数据会一条一条的蹦出来
#                                           类似：
#                                               email
#                                               a@qq.com
#                                               b@qq.com
#                                               a@qq.com
#                                               c@qq.com
#                                               a@qq.com
#                                               b@qq.com
#字符函数：lower转换小写，upper 转化大写, LENGTH计算字符串长度 BINARY（关键字不是函数）区分大小写 CONCAT拼接字符串
SELECT name,count(name) ,lower(name), LENGTH(name) AS '小写转换' FROM employee WHERE name like 'e%' GROUP BY name;
SELECT name,count(name) ,upper(name), LENGTH(name) AS '小写转换' FROM employee WHERE name like 'e%' GROUP BY name;
SELECT department,count(name)  AS '大写转换' FROM employee WHERE name like 'e%' GROUP BY department;
SELECT employee.department, COUNT(employee.salary) FROM employee WHERE salary >25000 AND employee.age <40 GROUP BY employee.department;
SELECT CONCAT('HELLO',' ','MySQL');
SELECT CONCAT('I' , ' LOVE LYT');
# LPAD(str, len, padstr)：在字符串 str 左侧用 padstr 填充，使结果达到 len 个字符；若 str 原长度大于 len，则截取其左侧前 len 个字符。
# RPAD(str, len, padstr)：在字符串 str 右侧用 padstr 填充，使结果达到 len 个字符；若 str 原长度大于 len，则截取其左侧前 len 个字符。
SELECT LPAD('LYT', 10, 'I LOVE ');
SELECT RPAD('I LOVE ', 10, 'LYT');
-- LTRIM(str)：去除字符串 str 左侧的普通空格，保留右侧及中间的空格；若 str 为 NULL，则返回 NULL。
-- RTRIM(str)：去除字符串 str 右侧的普通空格，保留左侧及中间的空格；若 str 为 NULL，则返回 NULL。
SELECT LTRIM('   hello   ');
SELECT RTRIM('   hello   ');
-- REPLACE(str, from_str, to_str)：将字符串 str 中所有匹配 from_str 的内容替换为 to_str；若任意参数为 NULL，则返回 NULL。
SELECT REPLACE('banana', 'a', 'x');#例如，把字符串中的所有 'a' 替换成 'x'。
-- REVERSE(str)：将字符串 str 中的字符顺序反转；若 str 为 NULL，则返回 NULL。
SELECT REVERSE('hello');
-- SUBSTR(str, pos, len) / SUBSTRING(str, pos, len)：从字符串 str 的第 pos 个字符开始截取 len 个字符（len 可省略，默认截取到末尾；pos 为负数时从右侧计数）；参数为 NULL 时返回 NULL。
SELECT SUBSTR('abcdef', 2, 3);
#ROUND()	四舍五入	ROUND(3.1415, 2) → 3.14,负数表示向小数点左侧移
SELECT ROUND(3.1415, 2) AS '约分结果' ;
SELECT ROUND(3.1415, -1) AS '约分结果' ;
#TRUNCATE()	截断小数，不四舍五入
SELECT TRUNCATE(3.149, 2);
#MOD()	求余数
SELECT MOD(10, 3);
# CEIL() 向上取整，返回大于或等于该数的最小整数
SELECT CEIL(3.2) AS '向上取整结果';   # 4
SELECT CEIL(-3.2) AS '向上取整结果';  # -3
# FLOOR() 向下取整，返回小于或等于该数的最大整数
SELECT FLOOR(3.8) AS '向下取整结果';   # 3
SELECT FLOOR(-3.2) AS '向下取整结果';  # -4
# ABS() 求绝对值
SELECT ABS(-10) AS '绝对值结果';       # 10
SELECT ABS(3.14) AS '绝对值结果';      # 3.14
# RAND() 生成 0（包含）到 1（不包含）之间的随机数
SELECT RAND() AS '随机数结果';
# RAND(N) 使用指定种子生成可重复的伪随机数
SELECT RAND(10) AS '随机数结果';
# POW() 计算一个数的指定次幂
SELECT POW(2, 3) AS '幂运算结果';      # 8
SELECT POW(5, 2) AS '幂运算结果';      # 25
# SQRT() 求平方根，负数会返回 NULL
SELECT SQRT(25) AS '平方根结果';       # 5
SELECT SQRT(81) AS '平方根结果';       # 9
SELECT SQRT(-4) AS '平方根结果';       # NULL
# SIGN() 判断数字的正负：正数返回 1，负数返回 -1，零返回 0
SELECT SIGN(10) AS '符号结果';         # 1
SELECT SIGN(-10) AS '符号结果';        # -1
SELECT SIGN(0) AS '符号结果';          # 0
# PI() 返回圆周率 π
SELECT PI() AS '圆周率';               # 约 3.141593
# MOD() 求余数
SELECT MOD(10, 3) AS '求余结果';       # 1
SELECT MOD(10, 2) AS '求余结果';       # 0
# GREATEST() 返回参数中的最大值
SELECT GREATEST(10, 20, 5, 30) AS '最大值';  # 30
# LEAST() 返回参数中的最小值
SELECT LEAST(10, 20, 5, 30) AS '最小值';     # 5

# --------------------------------------------日期函数--------------------------------------------------------------
# 在MySQL中允许直接使用字符串表示日期，但是要求字符串的日期格式必须为:YYYY-MM-DD HH:MI:SS' 或者YYYY/MM/DD HH:MI:SS';
# CURDATE() 获取当前日期
SELECT CURDATE() AS '当前日期';
# 示例结果：2026-10-19
# CURRENT_DATE() 与 CURDATE() 作用相同
SELECT CURRENT_DATE() AS '当前日期';
#获取当前时间 CURTIME/CURRENT_TIME功能一样只是名字不一样
SELECT CURRENT_TIME() AS '当前时间';
SELECT CURTIME() AS '当前时间';
# DATE（） 从日期或日期时间表达式中提取日期值
SELECT DATE('2005-1-8') AS '老婆的生日';
#NOW() 获取当前时间
SELECT NOW() AS '当前时间';
DESC employee;
ALTER TABLE employee ADD COLUMN cretime DATETIME;
INSERT INTO employee VALUES (155,'v','v','v','dp1','123452','45','2077-1-1');
SELECT * FROM lyt.employee where name LIKE 'V%';