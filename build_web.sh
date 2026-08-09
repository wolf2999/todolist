#!/usr/bin/env bash
# ============================================================================
#  Flutter Web Release 构建脚本
#  用法:
#    ./build_web.sh              # 仅构建到 build/web
#    ./build_web.sh --gh-pages   # 构建并复制到 docs/ (供 GitHub Pages 使用)
#
#  部署目标说明:
#   - Cloudflare Pages / Vercel / Netlify: 直接用 build/web 目录即可，
#     根域名托管，无需 base-href。各平台 Build 填 `flutter build web --release`，
#     Output 填 `build/web`。
#   - GitHub Pages: 需放子路径 /todolist/，用 --gh-pages 把产物复制到 docs/，
#     并在仓库 Settings -> Pages 选 main 分支 /docs 目录。
#     (注意: GitHub Pages 需要在构建时加 --base-href "/todolist/"，见下方注释)
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 如需部署到 GitHub Pages 子路径，把下面这行注释打开并删掉普通的 build 行:
# flutter build web --release --base-href "/todolist/"
flutter build web --release

if [ "$1" = "--gh-pages" ]; then
  echo ">>> 复制构建产物到 docs/ (GitHub Pages)"
  rm -rf docs
  mkdir -p docs
  cp -R build/web/. docs/
  echo ">>> 完成。请执行: git add docs && git commit -m 'web release' && git push"
fi

echo ">>> Web release 构建完成，产物位于: build/web"
du -sh build/web
