#!/bin/bash
set -e

# 配置项（通过环境变量传入）
REPO_URL="${REPO_URL:-https://github.com/basketikun/chatgpt2api.git}"
BRANCH="${BRANCH:-main}"
APP_DIR="/app/chatgpt2api"

echo "🚀 启动更新与部署流程..."

# 1. 克隆或更新代码
if [ -d "$APP_DIR/.git" ]; then
    echo "📦 代码目录已存在，执行 git pull 更新..."
    cd "$APP_DIR"
    git fetch --all
    git reset --hard "origin/$BRANCH"
    git pull origin "$BRANCH"
else
    echo "📥 首次运行，克隆代码仓库..."
    git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"
    cd "$APP_DIR"
fi

# 2. 安装 Python 依赖
echo "🐍 安装 Python 依赖..."
uv sync

# 3. 安装前端依赖并构建
echo "📦 安装前端依赖..."
cd "$APP_DIR/web"
npm install
echo "🔨 构建前端..."
npm run build

# 4. 回到项目根目录
cd "$APP_DIR"

# 5. 直接启动主服务（所有配置由环境变量提供）
echo "🌟 启动 ChatGPT2API 服务..."
exec uv run uvicorn main:app --host 0.0.0.0 --port 8080 --access-log
