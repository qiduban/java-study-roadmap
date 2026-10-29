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
-- 注意：cretime 列后来已经加到 employee 表里了，重复执行会报 Duplicate column，故注释保留
-- ALTER TABLE employee ADD COLUMN cretime DATETIME;
-- 注意：employee 表后来新增了 dept_id、manager_id、commission 列，早期 8 列的 INSERT 已不匹配；
-- 这里按当前 11 列改写，并用 INSERT IGNORE 避免 id=155 已存在时主键冲突
INSERT IGNORE INTO employee
    (id, name, first_name, last_name, department, dept_id, manager_id, salary, commission, age, cretime)
VALUES (155, 'v', 'v', 'v', 'SA_REP', 3, NULL, 123452.00, NULL, 45, '2077-01-01 00:00:00');
SELECT * FROM lyt.employee where name LIKE 'V%';
#STR_TO_DATE将字符串类型转化成datetime类型
INSERT IGNORE INTO employee
    (id, name, first_name, last_name, department, dept_id, manager_id, salary, commission, age, cretime)
VALUES (156, '王梦燊', '梦燊', '王', 'AD_VP', 4, NULL, 120000.00, NULL, 19, STR_TO_DATE('2007年4月25日','%Y年%m月%d日'));
SELECT employee.cretime FROM employee WHERE name = '王梦燊';
# ==================== 年份、月份、日期 ====================

# %Y  四位年份，例如 2026
# %y  两位年份，例如 26

# %M  月份英文全名，例如 October
# %b  月份英文缩写，例如 Oct
# %m  月份，补零，范围 01-12
# %c  月份，不补零，范围 1-12

# %D  带英文序数后缀的日期，例如 25th
# %d  日期，补零，范围 01-31
# %e  日期，不补零，范围 1-31
# %j  一年中的第几天，范围 001-366


# ==================== 小时、分钟、秒 ====================

# %H  24小时制小时，范围 00-23
# %k  24小时制小时，不补零，范围 0-23

# %h  12小时制小时，范围 01-12
# %I  12小时制小时，范围 01-12
# %l  12小时制小时，不补零，范围 1-12

# %i  分钟，范围 00-59
# %s  秒，范围 00-59
# %S  秒，范围 00-59
# %f  微秒，六位数字

# %p  上午或下午，例如 AM、PM
# %r  12小时制时间，例如 02:30:25 PM
# %T  24小时制时间，例如 14:30:25


# ==================== 星期、周数 ====================

# %W  星期英文全名，例如 Monday
# %a  星期英文缩写，例如 Mon
# %w  星期数字，星期日为0，星期六为6

# %U  周数，星期日为一周第一天，范围 00-53
# %u  周数，星期一为一周第一天，范围 00-53

# %V  周数，星期日为一周第一天，范围 01-53
# %X  与%V配套的四位周所属年份

# %v  周数，星期一为一周第一天，范围 01-53
# %x  与%v配套的四位周所属年份


# ==================== 其他 ====================

# %%  输出一个百分号 %

#==================== 例子 ====================
# DATE_FORMAT() 将日期格式化为字符串
SELECT DATE_FORMAT(
               '2026-10-19 14:30:25',
               '%Y-%m-%d %H:%i:%s'
       ) AS '格式化日期';
# 结果：2026-10-19 14:30:25
# 显示中文日期
SELECT DATE_FORMAT(
               '2026-10-19',
               '%Y年%m月%d日'
       ) AS '中文日期';
# 结果：2026年10月19日
# 显示星期英文名称
SELECT DATE_FORMAT(
               '2026-10-19',
               '%W'
       ) AS '星期';
# 结果：Monday
# 显示12小时制时间及上午、下午
SELECT DATE_FORMAT(
               '2026-10-19 14:30:25',
               '%r'
       ) AS '时间';
# 结果：02:30:25 PM
# CAST() 将值转换为指定的数据类型
SELECT CAST('123' AS SIGNED) AS '转换结果';       # 123
SELECT CAST('3.1415' AS DECIMAL(10,2)) AS '转换结果'; # 3.14
SELECT CAST(123 AS CHAR) AS '转换结果';            # '123'
SELECT CAST('2026-10-20' AS DATE) AS '转换日期';   # 2026-10-20

# CONVERT() 将值转换为指定的数据类型
SELECT CONVERT('123', SIGNED) AS '转换结果';       # 123
SELECT CONVERT(123, CHAR) AS '转换结果';            # '123'

# DATE_FORMAT() 将日期转换为指定格式的字符串
SELECT DATE_FORMAT('2026-10-20', '%Y-%m-%d') AS '日期';
SELECT DATE_FORMAT('2026-10-20', '%Y年%m月%d日') AS '日期';

# STR_TO_DATE() 将字符串按照指定格式解析为日期
SELECT STR_TO_DATE('2026-10-20', '%Y-%m-%d') AS '日期';
SELECT STR_TO_DATE('20/10/2026', '%d/%m/%Y') AS '日期';

# 隐式类型转换：MySQL 自动进行类型转换
SELECT '123' + 10 AS '计算结果';                  # 133
SELECT 10 = '10' AS '比较结果';# 1
# ================================================= 通用函数 ======================================================
# IF(条件, 条件成立时的值, 条件不成立时的值)
SELECT IF(1 > 0, '正确', '错误') AS '判断结果';
SELECT IF(salary > 10000, 'H', 'L'), COUNT(*) AS '工资等级' FROM employee GROUP BY IF(salary > 10000, 'H', 'L');
# IFNULL(值1, 备用值)判断是否为空为空则用备用值替换
SELECT IFNULL(NULL, 'Hello World');
-- Hello World
SELECT IFNULL(100, 0);
-- 100
# ISNULL()：判断是否为空
SELECT ISNULL(NULL);  -- 1
SELECT ISNULL(100);   -- 0
# NULLIF()：相等就返回 NULL 记忆：两个值一样，变成空值；不一样，返回第一个值
SELECT NULLIF(25, 25);  -- NULL
SELECT NULLIF(25, 30);  -- 25
# 实际应用中，可以用它避免分母为 0 的除法问题：
# SELECT profit / NULLIF(revenue, 0)
# FROM sales;
# COALESCE()：从左向右寻找第一个非 NULL 值,可以提供多个候选值。如果全部都是 NULL，结果就是 NULL。
SELECT COALESCE(NULL, NULL, 'bjxt.com', 'google.com');
-- bjxt.com
# CASE WHEN：多条件分支判断类似Java中的switch
# CASE
#     WHEN 条件1 THEN 结果1
#     WHEN 条件2 THEN 结果2
#     ELSE 默认结果
# END
SELECT CASE
WHEN employee.age >= 50 THEN 'GZL'
    WHEN age < 50 THEN 'NZL'
                 END
    ,COUNT(*)
FROM employee GROUP BY CASE
    WHEN employee.age >= 50 THEN 'GZL'
    WHEN age < 50 THEN 'NZL'
    END;
SELECT last_name, commission , (salary + salary * 12 *IFNULL(commission,0)) AN FROM employee;
SELECT employee.first_name,
       last_name,
       LENGTH(employee.first_name) 'EXP1',
       LENGTH(last_name) 'EXP2',
       NULLIF(LENGTH(first_name),LENGTH(last_name))
FROM employee;
# 例题 1:
# 查询员工表，显示他们的名字，如果COMMISSION_PCT值是非空，显示它。
# 如果COMMISSION PCT值是空，则显示SALARY。
# 如果COMMISSION PCT和SALARY值都是空，那么显示10。
# 在结果中对佣金列升序排序。
SELECT employee.name , COALESCE(employee.commission, employee.salary, 10)
FROM employee
ORDER BY
    commission;
# 例题 2:
# 查询员工表，如果JOB_ID是IT_PROG，薪水增加10%;
# 如果JOB_ID是ST_CLERK，薪水增加15%;
# 如果JOB_ID是SA_REP，薪水增加20%。对于所有其他的工作角色，不增加薪水
DESC employee;
SELECT employee.name, employee.department, employee.salary,
       CASE department
           WHEN 'IT_PROG' THEN salary * 1.10
           WHEN 'ST_CLERK' THEN  salary * 1.13
           WHEN 'SA_REP' THEN salary * 1.20
           ELSE salary
END AS 'RETINE_SALARY'
           FROM employee;
SELECT employee.cretime, employee.department, employee.name
FROM employee
WHERE cretime BETWEEN '1998-1-1' AND '2026-1-1'
ORDER BY cretime ASC;
SELECT employee.last_namE, LENGTH(employee.name) FROM employee WHERE
                                                              last_name LIKE 'J%'
OR
                                                              last_name LIKE 'A%'
OR
                                                              last_name LIKE 'M%'
ORDER BY LENGTH(last_name) ASC;
# 笛卡尔乘积:
# 当一个连接条件无效或被遗漏时，其结果是一个笛卡尔乘积(Cartesianproduct)，
# 其中所有行的组合都被显示。第一个表中的所有行连接到第二个表中的所有行。一个笛卡尔乘积会产生大量的行，其结果没有什么用。
# 你应该在WHERE子句中始终包含一个有效的连接条件除非你有特殊的需求，需要从所有表中组合所有的行。
# =========================================内连接与外连接==============================================
-- 内连接（INNER JOIN）：只返回两张表中满足关联条件的记录，不匹配的数据会被过滤掉。
-- 左外连接（LEFT JOIN）：保留左表的所有记录，右表匹配不到时，右表字段为 NULL。
-- 右外连接（RIGHT JOIN）：保留右表的所有记录，左表匹配不到时，左表字段为 NULL。
-- 全外连接（FULL OUTER JOIN）：保留左右两张表的所有记录，匹配不到的字段用 NULL 填充。
-- 注意：MySQL 不直接支持 FULL OUTER JOIN，可通过 LEFT JOIN、RIGHT JOIN 和 UNION 等方式实现类似效果。
# ====================================等值连接========================================
#1.显示写法
SELECT name, salary, employee.dept_id, department.dept_name
FROM employee
         JOIN department
              ON employee.dept_id = department.dept_id
WHERE department.dept_id = 4;
#2.隐式写法
SELECT employee.name, department.dept_name
FROM department, employee
WHERE employee.dept_id = department.dept_id
AND department.dept_id = 4;
# ==================================== 非等值连接 ==================================================
# 隐式写法
SELECT employee.name, employee.salary, salary_grade.grade_name
FROM employee, salary_grade
WHERE salary
BETWEEN min_salary AND max_salary;
# 显式写法
SELECT employee.name, employee.salary, salary_grade.grade_name
FROM employee
JOIN salary_grade
ON salary BETWEEN min_salary AND max_salary
ORDER BY employee.salary ASC ;

# ===================================== 自连接 =================================================
# 显示连接
SELECT e.id, e.name, e.salary, d.dept_name, d.dept_id, m.name
FROM employee e
join employee m
ON e.manager_id = m.id
JOIN lyt.department d on d.dept_id = e.dept_id
ORDER BY e.manager_id DESC;
# 隐式连接
SELECT e.id, e.name,e.salary, d.dept_name, d.dept_id, m.name
FROM employee e, employee m,department d
WHERE e.manager_id = m.id AND e.dept_id = d.dept_id
AND m.name = '王梦燊'
ORDER BY e.manager_id DESC;
# =====================================交叉连接=============================================
#显示写法
SELECT *
FROM employee
CROSS JOIN department;
#隐式写法
SELECT *
FROM department ,employee;
# 交叉连接是多表查询中的一种连接方式。它和你之前学习的等值连接、自连接不同，最核心的特点是：
# 交叉连接会将一张表中的每一行，与另一张表中的每一行进行组合，生成所有可能的组合结果。
# 这种结果也叫作笛卡尔乘积。
# =====================================自然连接==============================
#显式写法
SELECT employee.name, department.dept_name, IF(salary > 20000 ,'G' , 'D') AS 'LEVEL'
FROM employee
NATURAL JOIN lyt.department;
# 重要注意事项：
# 自然连接不需要手动写 ON。
# 所有同名字段都会参与连接条件，不只是其中一个。
# 使用 SELECT * 时，共同的连接字段只显示一次。
# 如果两张表中有多个同名字段，可能导致意外的匹配结果。
# 如果表中没有同名字段，通常会形成所有可能的行组合。
# ====================================================内连接====================================================
SELECT e.name AS '员工名',
       e.salary AS '员工薪水',
       d1.dept_name AS '员工部门',
       m.name AS '领导名',
       m.salary AS '领导薪水',
       d2.dept_name AS '领导部门'
FROM employee e
JOIN employee m
ON e.manager_id = m.id
JOIN department d1
    on e.dept_id =  d1.dept_id
JOIN department d2
    on m.dept_id =  d2.dept_id ;
# ====================================================外连接====================================================
# 外连接与内连接的关键区别是：即使指定一侧的记录没有匹配成功，也会将这条记录保留下来。
-- 左外连接（LEFT JOIN）：保留左表的所有记录，右表匹配不到时，右表字段为 NULL。
-- 右外连接（RIGHT JOIN）：保留右表的所有记录，左表匹配不到时，左表字段为 NULL。
SELECT e.name, d.dept_name
FROM employee e
LEFT JOIN lyt.department d on d.dept_id = e.dept_id;
# ++++++++左外连接++++++++++
# Michael Brown, null
# Sarah Chen, null
# David Kim, null
# Emma Wilson, null
# +++++++++右外连接+++++++++
SELECT e.name, d.dept_name
FROM employee e
         RIGHT JOIN lyt.department d on d.dept_id = e.dept_id;
# NULL,Quality Assurance Engineer
# +++++++++全外连接+++++++++
SELECT e.name, d.dept_name
FROM employee e
         LEFT JOIN lyt.department d on d.dept_id = e.dept_id;
SELECT e.name, d.dept_name
FROM employee e
         RIGHT JOIN lyt.department d on d.dept_id = e.dept_id;
# Michael Brown, null
# Sarah Chen, null
# David Kim, null
# Emma Wilson, null
# NULL,Quality Assurance Engineer
# 将所有含有孤儿数据的数据全列出来
# -------------------------------------聚合函数----------------------------------
-- 1. COUNT()：统计数量
SELECT COUNT(*) FROM employee;
-- 统计员工总人数

SELECT COUNT(salary) FROM employee;
-- 统计 salary 字段不为 NULL 的员工人数

SELECT COUNT(DISTINCT department) FROM employee;
-- 统计不重复的部门数量


-- 2. SUM()：求和
SELECT SUM(salary) FROM employee;
-- 计算所有员工的工资总和


-- 3. AVG()：求平均值
SELECT AVG(salary) FROM employee;
-- 计算所有员工的平均工资（忽略 NULL）


-- 4. MAX()：求最大值
SELECT MAX(salary) FROM employee;
-- 查询最高工资


-- 5. MIN()：求最小值
SELECT MIN(salary) FROM employee;
-- 查询最低工资


-- 6. GROUP BY：分组统计（常与聚合函数一起使用）
SELECT department, COUNT(*)
FROM employee
GROUP BY department;
-- 按部门分组，统计每个部门的员工人数


-- 7. WHERE：分组前过滤数据
SELECT department, AVG(salary)
FROM employee
WHERE salary > 7000
GROUP BY department;
-- 先筛选工资大于 7000 的员工，再按部门计算平均工资


-- 8. HAVING：分组后过滤结果
SELECT department, AVG(salary) AS avg_salary
FROM employee
GROUP BY department
HAVING AVG(salary) > 8000;
-- 查询平均工资大于 8000 的部门
# ----------------例子-----------------------
SELECT d.dept_name '部门名称',
       m.name '领导名字',
       AVG(e.salary) '平均值'
FROM employee e
JOIN lyt.department d on d.dept_id = e.dept_id
JOIN employee m ON E.manager_id = m.id
GROUP BY d.dept_name, m.name
order by avg(salary) desc ;

SELECT d.dept_name,
       employee.department,
       count(id),
       AVG(salary)
from employee
join lyt.department d on d.dept_id = employee.dept_id
group by d.dept_name, employee.department
HAVING AVG(salary) > 20000;
#用WHERE子句约束选择的行，用HAVING子句约束组,若未分组则不可以使用having

SELECT d.dept_name,
       SUM(employee.salary)
FROM employee
JOIN lyt.department d on d.dept_id = employee.dept_id
WHERE department NOT LIKE '%REP%'
GROUP BY d.dept_name
HAVING SUM(salary) > 350000
ORDER BY SUM(employee.salary);

# ==============================================子查询======================================================

#1.标量子查询
-- 查询工资高于公司平均工资的员工
SELECT d.dept_name,
       employee.name,
       employee.salary
FROM employee
JOIN lyt.department d on d.dept_id = employee.dept_id
WHERE employee.salary >(
        SELECT AVG(salary)
        FROM employee
    )
ORDER BY salary DESC ;
SELECT AVG(employee.salary) FROM employee;

#2.IN 子查询：判断是否在结果集合中
-- 查询工资超过 10000 的员工所在的部门
 SELECT *
 FROM department
 JOIN lyt.employee e on department.dept_id = e.dept_id
 WHERE department.dept_id IN (
     SELECT employee.id
     FROM employee
     WHERE salary > 10000
     );
-- 查询工资不超过 10000 的员工所在的部门
SELECT *
FROM department
         JOIN lyt.employee e on department.dept_id = e.dept_id
WHERE department.dept_id NOT IN (
    SELECT employee.id
    FROM employee
    WHERE salary > 10000
);
-- ============================================
-- ANY 和 ALL：多行子查询比较符的记忆方法
-- ============================================

-- ANY：任意一个
-- 只要与子查询返回的任意一个值比较成立，就满足条件。
-- 记忆：满足一个就可以（OR 的思路）。
--
-- ALL：所有
-- 必须与子查询返回的所有值比较都成立，才满足条件。
-- 记忆：所有都要满足（AND 的思路）。


-- 假设子查询返回两个工资：
-- 60000、90000


-- ============================================
-- 一、ANY：任意一个成立即可
-- ============================================

-- 1. 大于任意一个值
-- salary > 60000 OR salary > 90000
-- 对于非空且不含 NULL 的结果，相当于大于最小值
-- WHERE salary > ANY (子查询);

-- 2. 小于任意一个值
-- salary < 60000 OR salary < 90000
-- 对于非空且不含 NULL 的结果，相当于小于最大值
-- WHERE salary < ANY (子查询);

-- 3. 等于任意一个值
-- salary = 60000 OR salary = 90000
-- 常见情况下等价于 IN
-- WHERE salary = ANY (子查询);


-- ============================================
-- 二、ALL：所有条件都要成立
-- ============================================

-- 1. 大于所有值
-- salary > 60000 AND salary > 90000
-- 对于非空且不含 NULL 的结果，相当于大于最大值
-- WHERE salary > ALL (子查询);

-- 2. 小于所有值
-- salary < 60000 AND salary < 90000
-- 对于非空且不含 NULL 的结果，相当于小于最小值
-- WHERE salary < ALL (子查询);

-- 3. 不等于所有值
-- salary <> 60000 AND salary <> 90000
-- 即不能等于其中任何一个值
-- 常见情况下等价于 NOT IN（需注意 NULL）
-- WHERE salary <> ALL (子查询);


-- ============================================
-- 三、核心记忆口诀
-- ============================================

-- ANY = 任意一个：满足一个即可，记住 OR。
-- ALL = 所有：每一个都要满足，记住 AND。

-- > ANY：大于最小值即可（非空且不含 NULL）。
-- > ALL：必须大于最大值（非空且不含 NULL）。
-- < ANY：小于最大值即可（非空且不含 NULL）。
-- < ALL：必须小于最小值（非空且不含 NULL）。

-- 注意：
-- 上面的最小值、最大值简化规则，要求子查询结果非空且不含 NULL。
-- 如果结果包含 NULL 或者为空，比较结果需要单独分析。
#3.EXISTS 子查询
# EXISTS 用于判断子查询是否存在符合条件的记录。
# - 存在记录：EXISTS 为真。
# - 不存在记录：EXISTS 为假。
# 它关注的不是子查询返回什么值，而是有没有符合条件的记录。
-- 查询没有下单的客户
SELECT name AS Customers FROM Customers
where NOT EXISTS (SELECT 1
                  FROM Orders O
                  WHERE O.customerId = Customers.id
);
-- 查询有下单的客户
SELECT name AS Customers FROM Customers
where  EXISTS (SELECT 1
                  FROM Orders O
                  WHERE O.customerId = Customers.id
);
# 4.FROM 子查询：把查询结果当作临时表
# FROM 后面的括号中写的是一个查询。MySQL 会将这个查询的结果作为外层查询的数据来源。
# 这种由 FROM 子查询产生的结果，叫作派生表（Derived Table）。
# 你可以暂时把它理解为一张临时的查询结果表。
# 注意：它不是通过 CREATE TABLE 创建的永久表，也不是自动保存在数据库中的新表；它只是在当前 SQL 查询中使用。

-- 筛选平均工资大于 8000 的部门
SELECT * FROM (SELECT d.dept_name,
                      avg(employee.salary) avg_salary
               FROM employee
                        JOIN lyt.department d on d.dept_id = employee.dept_id
               GROUP BY dept_name) t -- 派生表名不要忘
WHERE t.avg_salary>10000;
#==============================================窗口函数================================================================
-- ============================================
-- 一、窗口函数：Window Function
-- ============================================

-- 窗口函数可以对一组相关记录进行计算，
-- 同时保留每一行原始数据。
-- 常见用途：排名、累计求和、计算平均值等。

-- 基本语法：
-- 函数名() OVER (
--     PARTITION BY 分组字段
--     ORDER BY 排序字段
-- );


-- ============================================
-- 二、DENSE_RANK()：密集排名函数
-- ============================================

-- DENSE_RANK() 用于排名。
-- 相同的工资获得相同的排名，
-- 后续排名不会跳号。
--
-- 例如工资：90000、85000、85000、70000
-- 对应排名：1、2、2、3
--
-- 本题要求按照不同工资排名前三，
-- 因此适合使用 DENSE_RANK()。

SELECT id, name, salary,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employee;

-- ORDER BY salary DESC：
-- 按工资从高到低排序。
--
-- AS salary_rank：
-- 给计算出来的排名列设置别名 salary_rank。


-- ============================================
-- 三、OVER()：指定窗口函数的计算规则
-- ============================================

-- OVER() 用于指定窗口函数的计算范围和规则。
--
-- 例如：
-- DENSE_RANK() OVER (ORDER BY salary DESC)
--
-- 表示按照工资从高到低进行密集排名。
--
-- 窗口函数不会像 GROUP BY 那样
-- 将同组的多条员工记录合并成一条。


-- ============================================
-- 四、PARTITION BY：划分窗口
-- ============================================

-- PARTITION BY dept_id：
-- 按部门编号划分窗口。
--
-- 每个部门独立排名，排名从 1 开始。
--
-- 例如：
-- IT_PROG 部门的最高工资是第 1 名；
-- SA_REP 部门的最高工资也会是第 1 名。
--
-- 注意：
-- PARTITION BY 用于窗口计算；
-- GROUP BY 主要用于分组统计。

SELECT id, name, dept_id, salary,
       DENSE_RANK() OVER (
           PARTITION BY dept_id
           ORDER BY salary DESC
       ) AS salary_rank
FROM employee;


-- ============================================
-- 五、JOIN：连接员工表和部门表
-- ============================================

-- employee 表存储员工的姓名、工资和部门编号(dept_id)。
-- department 表存储部门编号(dept_id)和部门名称(dept_name)。
--
-- 两张表通过 employee.dept_id
-- 与 department.dept_id 对应关联。
--
-- JOIN 默认是 INNER JOIN，
-- 只返回两张表中能够匹配的记录。

SELECT
    e.name,
    e.salary,
    d.dept_name AS Department
FROM employee AS e
         JOIN department AS d
              ON e.dept_id = d.dept_id;


-- ============================================
-- 六、FROM 子查询：将查询结果作为派生表
-- ============================================

-- FROM (SELECT ...) AS t
--
-- 1. 内层查询先计算排名。
-- 2. 将内层查询的结果作为派生表。
-- 3. AS t 给派生表设置别名 t。
-- 4. 外层查询可以继续筛选派生表中的字段。
--
-- 注意：
-- 派生表不是永久创建的新表。
-- 外层只能访问内层 SELECT 输出的字段。


-- ============================================
-- 七、WHERE：筛选排名前三的员工
-- ============================================

-- WHERE salary_rank <= 3：
-- 只保留排名为 1、2、3 的员工。
--
-- 为什么放在外层？
-- 因为同一层的 WHERE 不能直接使用窗口函数
-- 的计算结果进行筛选。
--
-- 所以先在内层计算排名，
-- 再在外层通过 WHERE 筛选。


-- ============================================
-- 八、完整解法：LeetCode 第 185 题
-- ============================================

SELECT
    t.Department,            -- 返回部门名称
    t.Employee,              -- 返回员工姓名
    t.Salary                 -- 返回员工工资
FROM (
         -- 内层查询：计算每名员工在本部门的工资排名
         SELECT
             d.dept_name AS Department,  -- 获取部门名称
             e.name AS Employee,    -- 获取员工姓名
             e.salary AS Salary,    -- 获取员工工资

             -- DENSE_RANK()：密集排名
             -- PARTITION BY：每个部门单独排名
             -- ORDER BY salary DESC：工资从高到低排名
             DENSE_RANK() OVER (
                 PARTITION BY e.dept_id
                 ORDER BY e.salary DESC
                 ) AS salary_rank       -- 保存排名结果

         FROM employee AS e

                  -- 连接部门表，获取部门名称
                  JOIN department AS d
                       ON e.dept_id = d.dept_id

     ) AS t                          -- 给内层查询结果起别名 t

-- 外层查询：筛选每个部门工资排名前三的员工
WHERE t.salary_rank <= 3;

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++索引++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 1.普通索引
# 普通索引就是为表中的一个或多个字段建立的、没有唯一性约束的索引。
# 它主要用于加快查询速度，不要求索引中的值必须唯一
# 创建索引的格式
# CREATE INDEX index_name ON table(column(length));
/*
普通索引中的 length：前缀索引长度

1. 含义：
   length 表示索引字符串字段的前多少个字符或字节，
   不是字段长度限制，也不是 B+ 树的高度。

2. 创建方式：
   CREATE INDEX idx_name ON user(name(10));
   表示只对 name 的前 10 个字符建立索引。

3. 适用类型：
   - CHAR、VARCHAR：按字符计算。
   - BINARY、VARBINARY、BLOB：按字节计算。
   - TEXT、BLOB 类型建立索引时，通常需要指定前缀长度。
   - INT 等数值类型不能使用这种前缀索引写法。

4. 优点：
   减少索引占用的存储空间，降低索引维护成本。

5. 缺点：
   前缀越短，不同值的前缀越容易重复，可能增加需要检查的记录数，
   查询效率不一定优于完整索引。

6. 注意：
   - length 不能超过字段及数据库允许的索引长度限制。
   - 唯一前缀索引只保证前缀不重复，不保证完整字段值不重复。
   - SHOW INDEX FROM user; 可查看索引信息，
     其中 Sub_part 通常表示前缀长度。

示例：
   CREATE INDEX idx_name ON user(name(10));
   CREATE UNIQUE INDEX uk_name ON user(name(10));

适用场景：
   字符串较长、前缀具有较好区分度，并且希望减少索引空间时。
*/
CREATE INDEX idx_name ON employee(name);
#创建姓名索引 idx_name 为索引名每一个索引都需要一个名字
ALTER TABLE employee
    ADD INDEX idx_name (name);
#这也是添加索引的一种方式和上面是同一个效果
SHOW INDEX FROM employee;
#作用是展现已经创建的索引
SELECT * FROM employee
WHERE name = '张三';
#使用索引，查询效率更高
EXPLAIN
SELECT * FROM employee
WHERE name = '张三';
#EXPLAN查看是否使用了索引
# 假如执行计划中显示：
# possible_keys: idx_name
# key:           idx_name
# 代表MySQL选择了索引查询
EXPLAIN
SELECT * FROM employee FORCE INDEX (idx_name) -- 强制使用索引查找
WHERE name = '张三';
#删除索引 DROP INDEX idx_name ON TABLE_NAME;
DROP INDEX idx_name ON employee;
# -----------------------------唯一索引---------------------------------
# 普通索引、唯一索引、主键索引、组合索引，并不是四种完全互斥的东西。
# 普通索引和唯一索引主要区别在于是否约束唯一性；主键索引是一种特殊的唯一索引，同时承担标识记录的职责；组合索引则描述索引包含几个字段。
# 例如，一个索引既可以是唯一索引，也可以是组合索引：
# 创建唯一性索引CREATE UNIQUE INDEX indexName ON table(column(length));
CREATE INDEX uk_email ON employee(email(15)); -- 设置lenegth可以节省物理空间
# 添加唯一性索引
ALTER TABLE employee
    ADD UNIQUE INDEX uk_email(email);
SELECT employee.email FROM employee WHERE name = '王梦燊';
INSERT INTO employee(email) VALUES ('emp156@lyt.com'); -- 添加同一元素时MySQL会报错
# -----------------------------主键索引------------------------------
#     对比	主键约束（PRIMARY KEY）	主键索引（Primary Key Index）
#     本质	一种完整性约束	            一种数据库索引结构
#   主要作用	保证主键值唯一且非空	    加快查询、定位记录
#     关注点	数据是否合法	            数据如何存储和查找
# 是否允许重复值	不允许	        取决于索引类型；主键索引不允许重复
#  是否允许 NULL	不允许	        主键索引对应的主键列也不能为 NULL
#   如何创建	使用 PRIMARY KEY	    通常由数据库自动创建
# ------------------------------组合索引--------------------------------
# 组合索引（联合索引）是指将两个或多个字段组合建立在同一个索引中，
# 其作用是提高多条件查询的效率、减少数据扫描量，并遵循最左前缀匹配原则。

# 组合索引也叫多列索引，是指一个索引同时包含两个或更多字段。
CREATE INDEX id_depart_name ON employee(department,name);
EXPLAIN select employee.department,employee.name from employee;