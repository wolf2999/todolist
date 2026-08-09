# Flutter Web 部署指南（Vercel / Netlify / Cloudflare Pages）

本文档对比 **Vercel / Netlify / Cloudflare Pages** 三家主流前端托管平台在部署 **Flutter Web 静态产物** 上的差异，并给出**针对本项目（todolist）的具体接入步骤**。

---

## 1. 性能与定位对比

| 维度 | **Vercel** | **Netlify** | **Cloudflare Pages** |
|---|---|---|---|
| **首次部署耗时** | ~2 分钟 | ~2 分钟 | ~5 分钟（需装 Flutter SDK） |
| **国内/亚太访问速度** | ⭐⭐⭐ 中等 | ⭐⭐⭐ 中等 | ⭐⭐⭐⭐⭐ **最快** |
| **欧美访问速度** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **免费带宽/月** | 100 GB | 100 GB | **无限** |
| **自动 HTTPS** | ✅ | ✅ | ✅ |
| **支持私有仓库** | ✅ | ✅ | ✅ |
| **绑定自定义域名** | ✅ | ✅ | ✅ |
| **配置便利性** | ⭐⭐⭐⭐⭐ 最省心 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Flutter 社区文档** | 最丰富 | 一般 | 一般 |
| **Serverless 能力** | Node/Edge/Python（最全） | AWS Lambda 封装 | Cloudflare Workers（边缘最快但 API 约束多） |

### 选型结论

- **追求"国内访问最快 + 长期项目"** → Cloudflare Pages（本次 todolist 选用）
- **追求"零配置 + 5 分钟接入"** → Vercel
- **追求"折中 + 通用"** → Netlify

---

## 2. 访问地址规则

| 平台 | 默认域名格式 | 自定义域名支持 | 备注 |
|---|---|---|---|
| Vercel | `https://<project-name>.vercel.app` | ✅ 绑定任意域名 | 支持一级和子域名 |
| Netlify | `https://<project-name>.netlify.app` | ✅ 绑定任意域名 | 同上 |
| **Cloudflare Pages** | `https://<project-name>.pages.dev` | ✅ 绑定任意域名 | 命名必须全局唯一 |

> 注：Cloudflare Workers（与 Pages 不同的产品）默认是 `*.workers.dev`，没有 `pages.dev` 后缀。两者经常被混淆。

---

## 3. Flutter Web 产物说明

### 构建命令

```bash
flutter build web --release
```

### 产物结构（`build/web/`）

```
build/web/
├── index.html              # 入口
├── main.dart.js            # 编译后的 Dart 代码 (≈ 2.9 MB)
├── flutter.js              # Flutter 引擎 loader
├── flutter_bootstrap.js    # 启动脚本
├── flutter_service_worker.js  # PWA 离线缓存
├── assets/                 # 字体/图片 (≈ 2.6 MB)
│   ├── AssetManifest.bin
│   ├── FontManifest.json
│   ├── NOTICES.Z
│   ├── assets/fonts/Rubik/...
│   └── assets/images/...
├── canvaskit/              # 渲染引擎 (≈ 24 MB)
│   ├── canvaskit.wasm
│   ├── canvaskit.js
│   └── ...
├── icons/                  # 应用图标
├── favicon.png
├── manifest.json
└── version.json
```

### 体积优化选项

```bash
flutter build web --release --web-renderer html    # 改用 HTML 渲染器，canvaskit/ 消失，产物降到 ~5 MB
flutter build web --release --base-href "/todolist/"  # 用于子路径托管（如 GitHub Pages）
```

---

## 4. Cloudflare Pages 接入步骤（本项目当前采用）

### 4.1 准备工作

- 一个 Cloudflare 账号（已开通 Pages 服务）
- GitHub 私有仓库：`wolf2999/todolist`
- Flutter 版本锁定 3.29.3（与本地一致）

### 4.2 本项目配套脚本

仓库根目录已提供两个脚本：

| 脚本 | 用途 |
|---|---|
| `build_web.sh` | 本地构建：直接 `flutter build web --release` |
| `scripts/build_web_cf.sh` | **CI 环境专用**：先 clone Flutter 3.29.3，再构建 |

### 4.3 Cloudflare 控制台操作

1. 登录 https://dash.cloudflare.com
2. 左侧菜单 **Workers & Pages** → 右上角 **Create application**
3. 在弹窗底部点 **"Looking to deploy Pages? Get started"** 进入 Pages 入口
4. 选 **Pages** 标签 → **Import an existing Git repository** → **Get started**
5. 授权 GitHub → 选择仓库 `wolf2999/todolist`

### 4.4 构建配置

| 配置项 | 填写值 | 说明 |
|---|---|---|
| **Project name** | `todolist` | 决定默认域名为 `todolist.pages.dev` |
| **Production branch** | `main` | 推送到 main 自动触发构建 |
| **Framework preset** | `None` | Flutter 不在 CF 预设列表 |
| **Build command** | `./scripts/build_web_cf.sh` | CI 脚本会自动装 Flutter 3.29.3 并构建 |
| **Build output directory** | `build/web` | 与 Flutter 默认产物目录一致 |
| **Root directory** | （留空） | 必须在仓库根执行脚本 |
| **Environment variables** | 无需填写 | |

### 4.5 触发构建

点 **Save and Deploy**。首次约 3-6 分钟（要 clone Flutter 仓库），之后缓存加速到 1-2 分钟。

### 4.6 部署成功

部署成功后 CF 会给两个 URL：

| 类型 | URL |
|---|---|
| Production | `https://todolist.pages.dev` |
| Preview（每次 PR 自动生成） | `https://<commit-hash>.todolist.pages.dev` |

---

## 5. 关键问题与解决方案

### 5.1 CI 环境没有 Flutter SDK

CF 云端 Runner 默认不带 Flutter。**不能直接写 `flutter build web --release`**，否则会报 `flutter: command not found`。

**解决方案**：使用 `scripts/build_web_cf.sh`，脚本内容关键片段：

```bash
export FLUTTER_ROOT="/opt/buildhome/flutter"
if [ ! -d "$FLUTTER_ROOT" ]; then
  git clone --filter=blob-none https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
  git -C "$FLUTTER_ROOT" fetch --depth 1 origin tag 3.29.3
  git -C "$FLUTTER_ROOT" checkout 3.29.3
fi
export PATH="$FLUTTER_ROOT/bin:$PATH"
flutter pub get
flutter build web --release
```

### 5.2 Flutter 版本不一致导致依赖冲突（**本次踩坑**）

**症状**：
```
Because todolist depends on flutter_localizations from sdk which depends on intl 0.20.2,
intl 0.20.2 is required.
So, because todolist depends on intl ^0.19.0, version solving failed.
```

**根因**：
- 本地 Flutter 版本：`3.29.3`（要求 `intl ^0.19.0`）
- CI 默认装的是 `stable` 分支（某次实测为 `3.44.9`），要求 `intl ^0.20.2`
- 两者不兼容 → `flutter pub get` 失败

**解决方案**：CI 脚本显式锁定 Flutter 版本为 `3.29.3`，与本地一致。

> **教训**：CI 永远不要用 `stable` 分支，要用具体 tag。这样：
> 1. 构建可复现（不会因为 stable 滚动升级突然挂掉）
> 2. 与本地开发环境一致
> 3. 出问题时有明确的版本参照

### 5.3 拖拽上传不支持 wasm（已避开）

Cloudflare Pages 的 **Direct Upload（拖拽/zip）** 对 `.wasm` 文件类型有限制，会显示 `60 are unknown` 错误。

**解决方案**：放弃拖拽上传，改用 **Git 集成自动构建**（如上）。

### 5.4 canvaskit 体积大

`canvaskit/` 约 24 MB，包含 Skia 图形引擎的 WebAssembly 字节码。CDN 会按内容哈希强缓存，**用户首次下载后不会重复拉取**。

如果对首屏加载敏感：
```bash
flutter build web --release --web-renderer html
```
可让产物从 ~29 MB 降到 ~5 MB（代价：复杂动画/自定义绘制保真度下降，对 todolist 几乎无影响）。

---

## 6. Vercel 接入步骤（备选）

如果未来想迁移到 Vercel，配置更简单：

| 配置项 | 填写值 |
|---|---|
| Framework Preset | **Other** |
| Build Command | `flutter build web --release` |
| Output Directory | `build/web` |
| Install Command | （留空，Vercel 检测到 pubspec.yaml 会自动装 Flutter） |

> 注：Vercel 自 2024 年起对 Flutter 项目有内建支持，会自动安装 Flutter stable。如果遇到 `intl` 冲突，可在 `Environment Variables` 加 `FLUTTER_VERSION=3.29.3` 锁定版本。

### Vercel 优势 / 劣势

**优势**：
- 5 分钟接入，配置最简单
- 文档最全，Flutter 社区案例最多
- 预览部署体验最好（每次 PR 自动生成独立 URL）

**劣势**：
- 免费带宽 100 GB/月，Flutter Web canvaskit 24MB，单用户首次访问就占不少
- 国内访问速度中等（节点偏欧美）

---

## 7. Netlify 接入步骤（备选）

`Site settings → Build & deploy`：

| 配置项 | 填写值 |
|---|---|
| Base directory | （留空） |
| Build command | `flutter build web --release` |
| Publish directory | `build/web` |
| Environment variables | `FLUTTER_VERSION=3.29.3`（可选，避免版本漂移） |

Netlify 不自动装 Flutter，**首次可能需要 nix 配置**或在 `netlify.toml` 中指定环境：

```toml
[build]
  command = "curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.3-stable.tar.xz | tar -xJ && export PATH=$PWD/flutter/bin:$PATH && flutter pub get && flutter build web --release"
  publish = "build/web"
```

### Netlify 优势 / 劣势

**优势**：
- 长期口碑稳，配置界面友好
- Forms / Identity 等附加功能强（适合做有表单的应用）

**劣势**：
- 不像 Vercel 对 Flutter 有原生支持，需要自己处理 Flutter 安装
- 国内访问速度与 Vercel 相近，没有 CF 快

---

## 8. 三家平台综合评分

按 **todolist 项目实际需求**（静态站点、国内访问、私有仓库、Flutter Web）打分（满分 5 ⭐）：

| 平台 | 速度 | 易用性 | Flutter 友好度 | 综合 |
|---|---|---|---|---|
| Vercel | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Netlify | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Cloudflare Pages** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 9. 日常使用流程

### 9.1 改了 Flutter 源码后自动部署

```bash
git add .
git commit -m "feat: xxx"
git push origin main
```
CF 检测到 main 分支有新 commit → 自动跑 `./scripts/build_web_cf.sh` → 部署到 `todolist.pages.dev`。

**整个流程约 1-3 分钟**（首次构建慢，后续有缓存）。

### 9.2 本地验证构建产物

```bash
./build_web.sh                    # 构建到 build/web
cd build/web && python3 -m http.server 8080  # 本地预览
```
访问 http://localhost:8080 验证页面表现。

### 9.3 想强制重新部署（不修改代码）

CF Pages → Deployments → 找到对应版本 → **Retry deployment**。

---

## 10. 后续可选优化

- **绑自有域名**：`todolist.你的域名.com`（CF 后台 Custom domains 加，DNS 配 CNAME，免费自动 HTTPS）
- **限制访问**：CF Pages 项目 → Settings → Access policies（可加邮箱 OTP 验证，仅自己可访问）
- **减体积**：构建加 `--web-renderer html`，从 29MB 降到 5MB
- **绑定数据库**：要做云同步时，可接 Supabase / Cloudflare D1（前端纯客户端，避免后端维护）