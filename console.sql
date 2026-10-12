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
CREATE TABLE demo(
  id INT PRIMARY KEY
);
#创建表时添加非空约束
CREATE TABLE demo1(
    id INT NOT NULL
);
#创建表时添加唯一约束
CREATE TABLE demo2(
    id INT,
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