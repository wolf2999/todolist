#!/usr/bin/env bash
# 项目级 Android 构建包装脚本。
# 由于本机 ninja 位于 Android SDK 的 cmake 目录内（不在默认 PATH），
# 这里统一把它的路径加入 PATH，避免每次手动 export。
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 常见 ninja 位置：Android SDK 的 cmake 包内
NINJA_DIR="$HOME/Library/Android/sdk/cmake/3.22.1/bin"
if [ -x "$NINJA_DIR/ninja" ]; then
  export PATH="$NINJA_DIR:$PATH"
fi

cd "$PROJECT_ROOT"
flutter build apk "$@"
