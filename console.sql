show databases ;
use lyt;
show tables ;
desc lyt.表名;
# # alter table 表名 change column 数据2 数据 varchar(255);
# desc 表名;
# ALTER TABLE 表名 DROP PRIMARY KEY;
# alter table 表名 CHANGE COLUMN 主键 主键 INT;
# DESC 表名;
# ALTER TABLE 表名 DROP PRIMARY KEY;
# DESC 表名;
# alter table 表名 add primary key (主键);
# alter table 表名 modify column 主键 int auto_increment;
# desc 表名;
SHOW DATABASES;
USE wms;
show tables;
use wms;
DESC girfirend;
#添加外键是要注意，参照表下的参照列必须是不可重复的，换言之必须为主键或者是唯一键
ALTER TABLE lyt.boyfirend ADD PRIMARY KEY (person_id);
# fk_*******_*****为自定义的外键名
ALTER TABLE girfirend ADD CONSTRAINT fk_girfirend_boyfirend FOREIGN KEY (person_id) references lyt.boyfirend(person_id);
# ALTER TABLE girfirend DROP FOREIGN KEY fk_girfirend_boyfirend;通过外键的名字来删除外键
ALTER TABLE girfirend DROP FOREIGN KEY fk_girfirend_boyfirend;
desc girfirend;
SHOW CREATE TABLE girfirend;
#添加唯一约束
# uk_person_id同样为约束名，删除也是通过删除约束名来删除
ALTER TABLE girfirend ADD CONSTRAINT uk_person_id UNIQUE (person_id);
SHOW CREATE TABLE girfirend;
ALTER TABLE girfirend DROP KEY uk_person_id;
SHOW CREATE TABLE girfirend;
#添加非空约束ALTER TABLE 表名 MODIFY 列名 类型 NOT NULL;
ALTER TABLE girfirend MODIFY person_id INT NOT NULL ;
SHOW CREATE TABLE girfirend;
#删除非空约束并不是通过删除约束名而是通过modify更改约束类型
ALTER TABLE girfirend MODIFY person_id INT NULL;
SHOW CREATE TABLE girfirend;
SHOW KEYS FROM girfirend;
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
SHOW CREATE TABLE demo;
SHOW CREATE TABLE demo1;
SHOW CREATE TABLE demo2;
SHOW CREATE TABLE demo3;
