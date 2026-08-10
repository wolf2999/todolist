// Cloudflare Pages Function: /api/admin/delete
// 受保护的管理接口：删除留言（按 id 列表，或按白名单字段过滤）。
// 请求头必须带 x-admin-key，值与 wrangler secret ADMIN_KEY 一致。
//
// 用法示例：
//   # 删指定 id
//   curl -X POST https://<domain>/api/admin/delete \
//     -H "x-admin-key: <KEY>" -H "content-type: application/json" \
//     -d '{"ids":[1,2,3]}'
//
//   # 按关键字模糊删 content（白名单字段，防注入）
//   curl -X POST https://<domain>/api/admin/delete \
//     -H "x-admin-key: <KEY>" -H "content-type: application/json" \
//     -d '{"where":{"field":"content","op":"like","value":"test"}}'
//
//   # 删全部某一天之前的（注意 created_at 单位是 ms）
//   curl -X POST https://<domain>/api/admin/delete \
//     -H "x-admin-key: <KEY>" -H "content-type: application/json" \
//     -d '{"where":{"field":"created_at","op":"lt","value":1700000000000}}'

interface Env {
  DB: D1Database;
  ADMIN_KEY: string;
}

interface Where {
  field: 'id' | 'content' | 'created_at';
  op: 'eq' | 'ne' | 'like' | 'gt' | 'gte' | 'lt' | 'lte';
  value: string | number;
}

interface Body {
  ids?: number[];
  where?: Where;
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

// 严格白名单：仅允许这些字段 + 操作符的组合，构造 SQL 时直接拼接标识符，
// 任何值用 .bind() 参数化，杜绝注入。
const FIELD_MAP: Record<Where['field'], string> = {
  id: 'id',
  content: 'content',
  created_at: 'created_at',
};
const OP_MAP: Record<Where['op'], string> = {
  eq: '=',
  ne: '!=',
  like: 'LIKE',
  gt: '>',
  gte: '>=',
  lt: '<',
  lte: '<=',
};

export const onRequestPost = async (ctx: { request: Request; env: Env }) => {
  const { request, env } = ctx;

  // 1) 校验管理密钥
  const key = request.headers.get('x-admin-key');
  if (!env.ADMIN_KEY || key !== env.ADMIN_KEY) {
    return json({ error: '未授权。' }, 401);
  }

  // 2) 解析请求体
  let body: Body;
  try {
    body = await request.json();
  } catch {
    return json({ error: '请求格式错误。' }, 400);
  }

  let stmt: D1PreparedStatement;
  if (body.ids && body.ids.length > 0) {
    const ids = body.ids.filter((n) => Number.isInteger(n) && n > 0);
    if (ids.length === 0) return json({ error: '未提供有效 id。' }, 400);
    const placeholders = ids.map(() => '?').join(',');
    stmt = env.DB.prepare(
      `DELETE FROM messages WHERE id IN (${placeholders})`
    ).bind(...ids);
  } else if (body.where) {
    const field = FIELD_MAP[body.where.field];
    const op = OP_MAP[body.where.op];
    if (!field || !op) {
      return json({ error: 'field/op 不在白名单内。' }, 400);
    }
    stmt = env.DB.prepare(
      `DELETE FROM messages WHERE ${field} ${op} ?`
    ).bind(body.where.value);
  } else {
    return json({ error: '请提供 ids 或 where 之一。' }, 400);
  }

  const { meta } = await stmt.run();
  return json({ ok: true, deleted: meta?.changes ?? 0 });
};
