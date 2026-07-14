# 使用 Python 3.11 作为基础镜像
FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 避免交互式安装提示
ENV DEBIAN_FRONTEND=noninteractive

COPY . .

# 安装 curl（用于健康检查）
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*  && \
    chmod +x /opt/start.sh

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# 暴露端口（根据 OpenList 的默认端口调整）
EXPOSE 5000

# 设置入口点
ENTRYPOINT ["/app/start.sh"]

USER 10014
