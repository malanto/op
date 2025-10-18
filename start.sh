#!/bin/bash
set -e
set -o pipefail

WORK_DIR="/opt/openlist"
FILE_NAME="openlist-linux-amd64.tar.gz"
URL="https://github.com/OpenListTeam/OpenList/releases/latest/download/$FILE_NAME"

echo "=== 启动 OpenList 容器 ==="
cd "$WORK_DIR"

# 清理旧文件
echo "[1/4] 清理旧文件..."
rm -f openlist.tar.gz

# 下载最新版本
echo "[2/4] 下载 OpenList..."
wget -q "$URL" -O openlist.tar.gz

# 解压
echo "[3/4] 解压文件..."
tar -zxf openlist.tar.gz
chmod +x ./openlist

# 启动服务（前台运行以保持容器存活）
echo "[4/4] 启动 OpenList..."
exec ./openlist server --no-prefix
