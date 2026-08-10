// Cloudflare Pages Function: /api/messages
// GET  -> 返回最近 N 条留言（按时间倒序）
// POST -> 新增留言（含 IP 时间窗口限流 + 长度校验）
//
// 环境变量（见 wrangler.toml）：
//   DB               D1 绑定
//   RATE_WINDOW_MS   同 IP 发帖最小间隔 (ms)
//   RATE_DAILY_LIMIT 同 IP 每天最多条数
//   MAX_LENGTH       单条最大字符数

interface Env {
  DB: D1Database;
  RATE_WINDOW_MS: number;
  RATE_DAILY_LIMIT: number;
  MAX_LENGTH: number;
}

function getClientIp(request: Request): string {
  // CF 真实访客 IP；不能直接用 x-forwarded-for（可被伪造）
  return request.headers.get('cf-connecting-ip') || 'unknown';
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      // 允许跨域（留言板独立 HTML 页面同源/或子路径访问）
      'access-control-allow-origin': '*',
    },
  });
}

export const onRequestOptions = async () =>
  new Response(null, {
    headers: {
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET, POST, OPTIONS',
      'access-control-allow-headers': 'content-type',
    },
  });

export const onRequestGet = async (ctx: { request: Request; env: Env }) => {
  const { env } = ctx;
  const { results } = await env.DB.prepare(
    `SELECT id, content, created_at FROM messages
     ORDER BY created_at DESC LIMIT 100`
  ).all();
  return json({ messages: results });
};

export const onRequestPost = async (ctx: { request: Request; env: Env }) => {
  const { request, env } = ctx;
  const ip = getClientIp(request);
  const now = Date.now();
  const today = new Date(now).toISOString().slice(0, 10); // YYYY-MM-DD (UTC)

  // 1) 读取限流记录
  const row = await env.DB.prepare(
    `SELECT count, day, last_post FROM rate_limits WHERE ip = ?`
  ).bind(ip).first<{ count: number; day: string; last_post: number }>();

  // 2) 时间窗口限制（60 秒内最多 1 条）
  if (row && row.day === today && now - row.last_post < env.RATE_WINDOW_MS) {
    const wait = Math.ceil((env.RATE_WINDOW_MS - (now - row.last_post)) / 1000);
    return json({ error: `发帖太频繁，请 ${wait}s 后再试。` }, 429);
  }

  // 3) 每日总量限制
  if (row && row.day === today && row.count >= env.RATE_DAILY_LIMIT) {
    return json({ error: '今日留言次数已达上限，明天再来吧。' }, 429);
  }

  // 4) 解析并校验内容
  let body: { content?: string };
  try {
    body = await request.json();
  } catch {
    return json({ error: '请求格式错误。' }, 400);
  }
  const content = (body.content || '').trim();
  if (!content) return json({ error: '留言内容不能为空。' }, 400);
  if (content.length > env.MAX_LENGTH) {
    return json({ error: `留言过长（最多 ${env.MAX_LENGTH} 字）。` }, 400);
  }

  // 5) 入库
  await env.DB.prepare(
    `INSERT INTO messages (content, created_at, ip) VALUES (?, ?, ?)`
  ).bind(content, now, ip).run();

  // 6) 更新限流计数（新的一天重置）
  const newCount = row && row.day === today ? row.count + 1 : 1;
  await env.DB.prepare(
    `INSERT INTO rate_limits (ip, count, day, last_post)
     VALUES (?, ?, ?, ?)
     ON CONFLICT(ip) DO UPDATE SET count = ?, day = ?, last_post = ?`
  ).bind(ip, newCount, today, now, newCount, today, now).run();

  return json({ ok: true }, 201);
};
