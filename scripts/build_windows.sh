#!/usr/bin/env bash
# ============================================================================
#  Windows 桌面端打包脚本 (需在 Windows 机器上运行)
#
#  作用：
#    1. flutter build windows --release  生成 Release 目录
#       (build/windows/x64/runner/Release/ —— 含 exe + 依赖 DLL + data/)
#    2. 把该目录整体打成 web/downloads/todolist-windows.zip
#       (相对路径与 lib/models/constants.dart 的 windowsExeUrl 对应)
#
#  用法：
#    ./scripts/build_windows.sh           # 仅打包 zip
#    ./scripts/build_windows.sh --no-build # 跳过编译，直接对已有 Release 目录打包
#
#  注意：
#    - 必须在 Windows 上执行 (flutter build windows 需要 MSVC 工具链)。
#    - 产物 zip 已就绪，部署 Web 时随 build/web 一起发布即可。
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

RELEASE_DIR="build/windows/x64/runner/Release"
OUT_DIR="web/downloads"
ZIP_NAME="todolist-windows.zip"

# 1) 编译 (除非显式跳过)
if [ "$1" != "--no-build" ]; then
  echo ">>> flutter build windows --release"
  flutter build windows --release
else
  echo ">>> 跳过编译 (--no-build)"
fi

# 2) 校验产物
if [ ! -d "$RELEASE_DIR" ]; then
  echo "✗ 未找到 Release 目录: $RELEASE_DIR" >&2
  echo "  请确认已在 Windows 上成功执行 flutter build windows --release" >&2
  exit 1
fi

# 3) 打包
mkdir -p "$OUT_DIR"
ZIP_PATH="$OUT_DIR/$ZIP_NAME"
echo ">>> 打包 $RELEASE_DIR -> $ZIP_PATH"
# 用 -C 进入目录，避免 zip 内出现 build/windows/... 的长路径前缀
( cd "$RELEASE_DIR" && zip -r -q "$SCRIPT_DIR/../$ZIP_PATH" . )

echo ">>> 完成: $ZIP_PATH"
du -h "$ZIP_PATH"
