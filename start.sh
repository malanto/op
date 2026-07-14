#!/bin/bash
set -e

# 配置项（通过环境变量传入）
REPO_URL="${REPO_URL:-https://github.com/basketikun/chatgpt2api.git}"
BRANCH="${BRANCH:-main}"
APP_DIR="/app/chatgpt2api"
PORT="${PORT:-8080}"

# 确保目录存在
mkdir -p "$APP_DIR"

# 删除目录下所有文件（包括隐藏文件），但保留目录本身
echo "🧹 清空目录内容: $APP_DIR"
rm -rf "$APP_DIR"/* "$APP_DIR"/.[!.]* "$APP_DIR"/..?* 2>/dev/null || true

echo "📥 首次运行，克隆代码仓库..."
git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$APP_DIR"
cd "$APP_DIR"

cd "$APP_DIR/web"
echo "🔨 构建前端..."
npm run build

# 4. 回到项目根目录
cd "$APP_DIR"

# 5. 直接启动主服务（所有配置由环境变量提供）
echo "🌟 启动 ChatGPT2API 服务..."
exec uv run uvicorn main:app --host 0.0.0.0 --port ${PORT} --access-log
