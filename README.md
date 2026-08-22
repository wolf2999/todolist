# 待办清单 To Do List

<p align="center">
  <img src="https://atodolist.pages.dev/icons/Icon-512.png" width="320" alt="To-Do List preview">
</p>

<p align="center">
  <a href="https://atodolist.pages.dev/"><img src="https://img.shields.io/badge/Live%20Demo-Open%20App-4A6CF7?style=flat-square&logo=googlechrome&logoColor=white" alt="Live Demo"></a>
  <img src="https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Desktop-4A6CF7?style=flat-square" alt="Platforms">
  <img src="https://img.shields.io/badge/Built%20with-Flutter-4A6CF7?style=flat-square&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License">
</p>

一个使用 Flutter 构建的待办事项（Todo List）应用，基于 *Rudi Hartono* 的设计稿改造而来，原稿可在 [Uplabs](https://www.uplabs.com/posts/to-do-list-app-freebie-kit) 查看。

本项目在原静态 UI 基础上，使用 **最新版 Flutter** 重写为 **全平台** 支持，并采用 **MVC（Model-View-Controller）** 架构，新增本地持久化、任务新增、完成勾选、滑动删除等真实可用的功能。

> 🌐 **Live Demo（在线体验）**：<https://atodolist.pages.dev/> — 无需安装，浏览器直接打开即可使用，并支持「添加到主屏幕」当作原生 App。

## 平台支持

- Web（开发默认平台）
- Android / iOS
- macOS / Linux / Windows

## 项目结构（MVC）

```
lib/
├── main.dart                        # 入口：注入 Controller、注册路由
├── controllers/
│   └── task_controller.dart         # Controller：状态管理 + 本地持久化
├── models/
│   └── task.dart                    # Model：任务数据结构
├── utils/
│   ├── colors.dart                  # 颜色常量
│   └── date_helper.dart             # 日期格式化工具
└── views/                           # View：仅负责展示与转发用户操作
    ├── onboarding.dart              # 启动引导页
    ├── home.dart                    # 主页面
    └── widgets/
        ├── custom_app_bar.dart      # 顶部进度条与头像
        ├── bottom_nav.dart          # 底部导航
        ├── task_fab.dart            # 新增按钮
        ├── task_tile.dart           # 任务条目（含勾选 / 滑动删除）
        ├── task_bottom_sheet.dart   # 新增任务表单
        └── empty_state.dart         # 空状态提示
```

## 快速开始 🚀

```bash
# 1. 安装依赖
flutter pub get

# 2. 在 Web 上运行（默认开发平台）
flutter run -d chrome

# 3. 其他平台示例
flutter run -d macos
flutter run -d android
flutter run -d ios
```

## 技术栈

| 用途         | 依赖                          |
| ------------ | ----------------------------- |
| 状态管理     | `provider`                    |
| 本地持久化   | `shared_preferences`          |
| 日期格式化   | `intl`                        |
| 跨平台图标   | `cupertino_icons`             |

## 主要功能

- ✅ 任务新增（底部表单 + 日期选择）
- ✅ 任务勾选完成 / 取消完成
- ✅ 左滑删除任务
- ✅ 顶部进度条统计完成情况
- ✅ 数据本地持久化（关闭应用后任务仍保留）
- ✅ 全平台一致体验（Web / 桌面 / 移动端）

## 在线体验 · Live Demo

直接打开 👉 **<https://atodolist.pages.dev/>** 即可在浏览器中使用完整功能，数据保存在本地。

<p align="center">
  <a href="https://atodolist.pages.dev/">
    <img src="https://atodolist.pages.dev/icons/Icon-512.png" width="420" alt="To-Do List app preview">
  </a>
</p>

- 支持「添加到主屏幕」以 PWA 方式安装为桌面/手机 App
- 内置留言板（Cloudflare Pages + D1，零服务器运维）
- 设置页一键「分享应用」，复制链接或唤起系统分享

## 下载

| 平台 | 下载 |
| ---- | ---- |
| Android (arm64) | [todolist-android.apk](https://github.com/wolf2999/todolist/releases/latest/download/todolist-android.apk) |
| Windows (免安装 zip) | [todolist-windows.zip](https://github.com/wolf2999/todolist/releases/latest/download/todolist-windows.zip) |
| Web (PWA) | <https://atodolist.pages.dev/> |

> 安装包由 GitHub Actions 在打 `v*` tag 时自动构建并发布到 [Releases](https://github.com/wolf2999/todolist/releases)，`latest/download` 链接始终指向最新版本。
> 分享给朋友：在设置页点击 **分享应用** 即可复制链接或唤起系统分享面板。

## 版本历史

| 版本 | 日期              | 说明                                                       |
| ---- | ----------------- | ---------------------------------------------------------- |
| 2.0  | 2026 / 08 / 09    | 基于最新 Flutter 重写，采用 MVC 架构，支持全平台，新增本地持久化 |
| 1.6  | 2021 / 05 / 19    | 迁移至 Flutter 2，新增子任务                                |
| 1.5  | 2019 / 12 / 10    | 构建由 production 改为 test                                 |
| 1.4  | 2019 / 09 / 26    | 在 Google Play 上架                                         |
| 1.3  | 2019 / 09 / 24    | 添加发布用 App 图标                                        |
| 1.2  | 2019 / 09 / 23    | 新增滑动删除                                                |
| 1.1  | 2019 / 09 / 16    | 状态栏设置为透明                                            |
| 1.0  | 2019 / 09         | 首次发布                                                    |

## 致谢

- UI 设计：[Rudi Hartono](https://www.uplabs.com/posts/to-do-list-app-freebie-kit)
- 原项目：参考 `../Flutter-Todolist` 目录下的 Flutter 项目

## 贡献

欢迎提交 Issue、Pull Request 或功能建议。

## 留言板（Cloudflare Pages + D1）

设置页「导入数据」下方新增了「留言板」入口，点击会在**新浏览器窗口**打开一个轻量的独立页面，
任何人无需登录即可留言。后端由 Cloudflare Pages Functions + D1 实现，零服务器运维。

### 架构
- `functions/api/messages.ts`：GET 返回最近 100 条留言；POST 新增（含 IP 时间窗口限流 + 长度校验）。
- `functions/api/admin/delete.ts`：受 `x-admin-key` 保护的删除接口，用于清理无用/垃圾留言。
- `migrations/0001_init.sql`：D1 表结构（`messages` + `rate_limits`）。
- `web/message_board.html`：独立留言板前端（不依赖 Flutter，由构建脚本拷贝到产物根）。
- `wrangler.toml`：D1 绑定与限流参数。

### 部署步骤
```bash
# 1. 安装并登录 wrangler
npm i -g wrangler
wrangler login

# 2. 创建 D1 数据库（记下输出的 database_id，填入 wrangler.toml 的 database_id）
wrangler d1 create todolist_messages

# 3. 执行迁移建表
wrangler d1 execute todolist_messages --file=./migrations/0001_init.sql --remote

# 4. 设置管理密钥（删除接口用，切勿写进代码仓库）
wrangler secret put ADMIN_KEY

# 5. 在 Cloudflare Pages 控制台设置：
#    Build command :  ./scripts/build_web_cf.sh
#    Build output :   build/web
#    并绑定 D1 数据库（名称 todolist_messages，变量名 DB）
```

### 后台清理留言
两种方式任选：
- **CF 控制台**：Storage & Databases → D1 → 你的数据库 → Console，直接跑 SQL：
  ```sql
  SELECT * FROM messages ORDER BY created_at DESC LIMIT 50;
  DELETE FROM messages WHERE id = 123;
  ```
- **删除接口**（批量）：
  ```bash
  curl -X POST https://<你的域名>/api/admin/delete \
    -H "x-admin-key: <ADMIN_KEY>" \
    -H "content-type: application/json" \
    -d '{"ids":[1,2,3]}'
  ```

### 限流策略（免费额度内）
- 同一 IP **60 秒内最多 1 条**（时间窗口，见 `wrangler.toml` 的 `RATE_WINDOW_MS`）。
- 同一 IP **每天最多 50 条**（自然日重置，见 `RATE_DAILY_LIMIT`）。
- 单条最长 500 字（`MAX_LENGTH`）。
- 真实 IP 取自 `cf-connecting-ip`（不信任 `x-forwarded-for`，防伪造）。

> 提示：匿名公开留言可能被机器人刷，如需更强防护可后续接入 Cloudflare Turnstile（免费）。

