use lyt;
drop function if exists f_grade;
create function f_grade(p_score int)
returns varchar(255)
deterministic
no sql
begin
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
    RETURN v_result;
end;
SELECT f_grade(95), f_grade(80), f_grade(60), f_grade(30), f_grade(NULL);

SET SESSION max_sp_recursion_depth = 10;
drop function if exists fun2;
create function fun2(num INT)
returns int
deterministic
no sql
begin
    if num = 1 then
        return 1;
    end if;
    return num*fun2(num-1);
end;
select fun2(5);‘
DELIMITER //

DROP TRIGGER IF EXISTS t_employee_before_insert//

CREATE TRIGGER t_employee_before_insert
    BEFORE INSERT ON trigger_employee_demo
    FOR EACH ROW
BEGIN

    -- 检查姓名
    IF NEW.name IS NULL OR TRIM(NEW.name) = '' THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '员工姓名不能为空';

    END IF;

    -- 检查工资
    IF NEW.salary < 0 THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '员工工资不能小于0';

    END IF;

    -- 自动去除姓名前后空格
    SET NEW.name = TRIM(NEW.name);

END//

DELIMITER ;



DELIMITER //

DROP TRIGGER IF EXISTS t_employee_after_insert//

CREATE TRIGGER t_employee_after_insert
    AFTER INSERT ON trigger_employee_demo
    FOR EACH ROW
BEGIN

    INSERT INTO trigger_employee_log (
        emp_id,
        operation_type,
        old_salary,
        new_salary,
        detail
    )
    VALUES (
               NEW.id,
               'INSERT',
               NULL,
               NEW.salary,
               CONCAT('新增员工：', NEW.name)
           );

END//

DELIMITER ;




















