-- D1 初始化：留言板所需的表
-- 在 CF 控制台或通过 wrangler 执行：
--   npx wrangler d1 execute todolist_messages --file=./migrations/0001_init.sql --remote

-- 留言表
CREATE TABLE IF NOT EXISTS messages (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  content     TEXT    NOT NULL,
  created_at  INTEGER NOT NULL,           -- Unix 毫秒时间戳
  ip          TEXT                       -- 发帖人 IP（仅用于后台排查，不展示）
);
CREATE INDEX IF NOT EXISTS idx_messages_created ON messages (created_at DESC);

-- 限流计数表：按 IP 记录当天发帖次数与最近一次发帖时间
CREATE TABLE IF NOT EXISTS rate_limits (
  ip          TEXT PRIMARY KEY,
  count       INTEGER NOT NULL DEFAULT 0,
  day         TEXT    NOT NULL,           -- YYYY-MM-DD（本地自然日）
  last_post   INTEGER NOT NULL            -- 最近一次发帖的 Unix 毫秒时间戳
);
