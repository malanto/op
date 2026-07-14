#!/bin/bash
set -e

# 配置项（通过环境变量传入）
REPO_URL="${REPO_URL:-https://github.com/basketikun/chatgpt2api.git}"
BRANCH="${BRANCH:-main}"
APP_DIR="/app/chatgpt2api"
PORT="${PORT:-8080}"

# === 关键：将 npm 的家目录设置为当前项目目录 ===
export npm_config_cache="$APP_DIR/.npm-cache"
export npm_config_tmp="$APP_DIR/.npm-tmp"
export npm_config_logs_dir="$APP_DIR/.npm-logs"

# 确保这些目录存在且有写入权限
mkdir -p "$npm_config_cache" "$npm_config_tmp" "$npm_config_logs_dir"

# 确保目录存在
mkdir -p "$APP_DIR"

# 删除目录下所有文件（包括隐藏文件），但保留目录本身
echo "🧹 清空目录内容: $APP_DIR"
rm -rf "$APP_DIR"/* "$APP_DIR"/.[!.]* "$APP_DIR"/..?* 2>/dev/null || true

echo "📥 首次运行，克隆代码仓库..."
git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$APP_DIR"
cd "$APP_DIR"

# 3. 安装前端依赖并构建
echo "📦 安装前端依赖..."
cd "$APP_DIR/web"
npm install --no-audit --no-fund --no-progress
echo "🔨 构建前端..."
npm run build

# 4. 回到项目根目录
cd "$APP_DIR"

# 5. 直接启动主服务（所有配置由环境变量提供）
echo "🌟 启动 ChatGPT2API 服务..."
exec uv run uvicorn main:app --host 0.0.0.0 --port ${PORT} --access-log
