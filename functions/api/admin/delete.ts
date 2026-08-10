// Cloudflare Pages Function: /api/admin/delete
// 受保护的管理接口：删除指定留言（或按 id 列表批量删）。
// 必须在请求头带 x-admin-key，值与 wrangler secret ADMIN_KEY 一致。
//
// 用法示例：
//   curl -X POST https://<your-domain>/api/admin/delete \
//     -H "x-admin-key: <ADMIN_KEY>" \
//     -H "content-type: application/json" \
//     -d '{"ids":[1,2,3]}'
//
// 设置密钥（不要写进 wrangler.toml，用 secret）：
//   wrangler secret put ADMIN_KEY

interface Env {
  DB: D1Database;
  ADMIN_KEY: string;
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'access-control-allow-origin': '*',
    },
  });
}

export const onRequestOptions = async () =>
  new Response(null, {
    headers: {
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'POST, OPTIONS',
      'access-control-allow-headers': 'content-type, x-admin-key',
    },
  });

export const onRequestPost = async (ctx: { request: Request; env: Env }) => {
  const { request, env } = ctx;

  // 1) 校验管理密钥
  const key = request.headers.get('x-admin-key');
  if (!env.ADMIN_KEY || key !== env.ADMIN_KEY) {
    return json({ error: '未授权。' }, 401);
  }

  // 2) 解析待删 id 列表
  let body: { ids?: number[] };
  try {
    body = await request.json();
  } catch {
    return json({ error: '请求格式错误。' }, 400);
  }
  const ids = (body.ids || []).filter((n) => Number.isInteger(n) && n > 0);
  if (ids.length === 0) return json({ error: '未提供有效 id。' }, 400);

  // 3) 参数化批量删除（防 SQL 注入）
  const placeholders = ids.map(() => '?').join(',');
  const { meta } = await env.DB.prepare(
    `DELETE FROM messages WHERE id IN (${placeholders})`
  ).bind(...ids).run();

  return json({ ok: true, deleted: meta?.changes ?? 0 });
};
