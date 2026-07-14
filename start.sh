#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/app/outlookEmail"
URL="https://github.com/assast/outlookEmail.git"
BRANCH="${BRANCH:-main}"
PORT="${PORT:-5000}"

# 确保目录存在
mkdir -p "$APP_DIR"

# 删除目录下所有文件（包括隐藏文件），但保留目录本身
echo "🧹 清空目录内容: $APP_DIR"
rm -rf "$APP_DIR"/* "$APP_DIR"/.[!.]* "$APP_DIR"/..?* 2>/dev/null || true

echo "=== 拉取代码 ==="
git clone --depth 1 -b "$BRANCH" "$URL" "$APP_DIR"

echo "进入目录"
cd "$APP_DIR"

echo "启动服务，端口: $PORT"
exec gunicorn \
  -k gthread \
  -w 1 \
  --threads "${GUNICORN_THREADS:-4}" \
  -b "0.0.0.0:${PORT}" \
  --timeout "${GUNICORN_TIMEOUT:-300}" \
  --graceful-timeout 30 \
  --access-logfile - \
  --error-logfile - \
  --capture-output \
  web_outlook_app:app
