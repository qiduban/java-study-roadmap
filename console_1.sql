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
select fun2(5);
























