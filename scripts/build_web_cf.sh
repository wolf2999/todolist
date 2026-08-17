#!/usr/bin/env bash
# ============================================================================
#  Cloudflare Pages 构建脚本 (CI 环境使用)
#  用于在 Cloudflare 云端 Runner 上安装 Flutter 并构建 Web 产物。
#  Cloudflare Pages 设置:
#    Build command :    ./scripts/build_web_cf.sh
#    Build output :     build/web
#    (本脚本默认产物输出到 build/web)
#
#  说明:
#    CF 云端默认没有 Flutter SDK，所以脚本会先克隆与本地一致的 3.29.3 tag 的 Flutter，
#    再加入 PATH 执行 pub get + build web --release。
#    本地开发请用根目录的 build_web.sh (不需要重复装 Flutter)。
# ============================================================================
set -e
set -x

# 1) 安装 Flutter (锁定与本地一致的 3.29.3，避免 stable 版本漂移导致依赖不兼容)
export FLUTTER_ROOT="/opt/buildhome/flutter"
if [ ! -d "$FLUTTER_ROOT" ]; then
  git clone --filter=blob:none https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
  git -C "$FLUTTER_ROOT" fetch --depth 1 origin tag 3.29.3
  git -C "$FLUTTER_ROOT" checkout 3.29.3
fi
export PATH="$FLUTTER_ROOT/bin:$PATH"

# 2) 预下载 Dart/Flutter 工具链 (首次需联网)
flutter doctor -v || true

# 3) 拉取依赖
flutter pub get

# 4) 构建 Web release 产物 (Flutter 3.29+ 渲染器按平台自动选择, 无需额外参数)
flutter build web --release

# 4.5) 自动打包 Android APK 并放入下载目录 (随每次部署更新)。
#     使用 --split-per-abi 仅出 arm64-v8a 包 (~12MB),避免超过 Cloudflare Pages 单文件 25MiB 上限。
#     产物写入 web/downloads/,随后 flutter build web 已结束,不会被清空;下载页 /downloads/app-release.apk 直接引用。
mkdir -p web/downloads
flutter build apk --release --split-per-abi
APK_SRC="build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
if [ -f "$APK_SRC" ]; then
  cp "$APK_SRC" web/downloads/app-release.apk
  echo ">>> 已生成 APK -> web/downloads/app-release.apk ($(du -h web/downloads/app-release.apk | cut -f1))"
else
  echo "!!! 未找到 arm64 APK:$APK_SRC,下载页将沿用仓库内已有文件(若有)。"
fi

# 5) 拷贝独立于 Flutter 的静态页面 (留言板) 到产物根。
#    flutter build web 会清空 build/web/ 重建，所以必须在 build 之后拷贝，
#    否则 message_board.html 会被删掉、/message_board.html 访问 404。
if [ -f "web/message_board.html" ]; then
  cp web/message_board.html build/web/message_board.html
  echo ">>> 已拷贝 message_board.html -> build/web/"
fi
if [ -f "web/message_board_admin.html" ]; then
  cp web/message_board_admin.html build/web/message_board_admin.html
  echo ">>> 已拷贝 message_board_admin.html -> build/web/"
fi

# 6) 拷贝 _routes.json，声明 /api/* 走 Functions（避免被 SPA fallback 拦截 GET）。
if [ -f "web/_routes.json" ]; then
  cp web/_routes.json build/web/_routes.json
  echo ">>> 已拷贝 _routes.json -> build/web/"
fi

echo ">>> CF build done. Output: build/web"
