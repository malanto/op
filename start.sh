#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="/out/outlookEmail"
URL="https://github.com/assast/outlookEmail.git"
BRANCH="${BRANCH:-main}"
PORT="${PORT:-5000}"

echo "=== 拉取代码 ==="

rm -rf "$WORK_DIR"
git clone --depth 1 -b "$BRANCH" "$URL" "$WORK_DIR"

echo "进入目录"
cd "$WORK_DIR"

echo "下载依赖"
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python -m pip install gunicorn

echo "创建数据目录"
mkdir -p /out/data

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
