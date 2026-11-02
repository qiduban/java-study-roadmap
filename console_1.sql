-- ============================================================
-- 脏读演示 · 事务 B（读事务，READ UNCOMMITTED）
-- ------------------------------------------------------------
-- 用法：放 Console 2，与 A 使用同一个数据源（127.0.0.1:3306，库 lyt）
-- 执行时机：A 执行到【步骤 5】之后
--
-- 预期结果：
--   【步骤 9】  B 读到 A 未提交的 1200.00  → 脏读
--   【步骤 12】 A 回滚后再读，变回 1100.00 → 脏数据消失
-- ============================================================
USE lyt;
-- 【步骤 7】B 使用最低隔离级别：读未提交
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 【步骤 8】开启事务 B
START TRANSACTION;

-- 【步骤 9】★★★ 关键：A 还没提交，B 却读到 1200.00 → 脏读 ★★★
SELECT account_name, balance FROM account WHERE account_name = '张三';

-- 【步骤 12】等 Console 1 的 A 执行 ROLLBACK 后，再执行这条
-- 预期：同一个事务 B 里，张三从 1200.00 变回 1100.00（脏读数据消失）
SELECT account_name, balance FROM account WHERE account_name = '张三';

-- 【步骤 13】结束事务 B
COMMIT;

-- ============================================================
-- 对照实验：REPEATABLE READ 不会脏读
-- 1) 让 Console 1 的 A 再执行一次【步骤 3】～【步骤 5】（UPDATE +100，不提交）
-- 2) Console 2 执行：
--      SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
--      START TRANSACTION;
--      SELECT account_name, balance FROM account WHERE account_name = '张三';
--    预期：仍是 1100.00（看不到 A 未提交的 1200.00）→ 没有脏读
-- 3) A 执行 ROLLBACK，B 执行 COMMIT
-- ============================================================

-- ============================================================
-- 不可重复读演示 · 事务 B（写事务：修改张三余额并提交）
-- ------------------------------------------------------------
-- 用法：Console 1（事务 A）执行完“第一次 SELECT”后，再执行本段
-- 顺序：A 第一次读 → B（本段）改余额并提交 → A 第二次读
-- 注意：B 这个 Console 也要是自动提交（autocommit=1），否则 SELECT 会提前开事务。
-- ============================================================
USE lyt;

-- 步骤 B0：确认基线（每次演示前应先把余额重置为 1100.00）
-- 重置语句（在 A 开始之前执行）：
-- UPDATE account SET balance = 1100.00 WHERE account_name = '张三';
SELECT account_name, balance FROM account WHERE account_name = '张三';

-- 步骤 B1：开启写事务 B，把张三余额改成 10000 并提交
START TRANSACTION;
UPDATE account SET balance = 10000 WHERE account_name = '张三';
COMMIT;

-- 步骤 B2：验证提交结果（应变成 10000.00）
SELECT account_name, balance FROM account WHERE account_name = '张三';

-- 收尾：两个演示都结束后，把余额改回 1100.00
-- UPDATE account SET balance = 1100.00 WHERE account_name = '张三';
-- COMMIT;

-- ============================================================
-- SERIALIZABLE 演示 · 事务 B（写事务：会被 A 的共享锁阻塞）
-- ------------------------------------------------------------
-- 执行时机：Console 1（A）执行完第一次 SELECT 之后
-- 现象：下面的 UPDATE 会一直等待（Waiting for lock），直到 A 执行 COMMIT 释放锁
-- 注意：B 也要是自动提交（autocommit=1）；默认 innodb_lock_wait_timeout=50 秒，超时会报 1205
-- ============================================================
USE lyt;

-- 步骤 B0：把锁等待超时调大一点，避免还没切回 A 就超时（可选）
SET SESSION innodb_lock_wait_timeout = 120;

-- 步骤 B1：开启事务 B；在 A 未提交前，这条 UPDATE 会被阻塞
START TRANSACTION;
UPDATE account SET balance = 10000 WHERE account_name = '张三';
COMMIT;

-- 步骤 B2：A COMMIT 后本条才会执行完；应看到 10000.00
SELECT account_name, balance FROM account WHERE account_name = '张三';

-- 收尾：演示结束后把余额改回 1100.00
-- UPDATE account SET balance = 1100.00 WHERE account_name = '张三';
-- COMMIT;