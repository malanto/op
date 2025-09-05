FROM ubuntu:22.04

# 设置工作目录
WORKDIR /opt/openlist

# 避免交互式安装提示
ENV DEBIAN_FRONTEND=noninteractive

# 定义环境变量名（值为空，由运行时传入）
ENV DB_TYPE= \
    DB_HOST= \
    DB_USER= \
    DB_PASS= \
    DB_PORT= \
    DB_NAME= \
    PORT=

# 更新包列表并安装必要的工具
RUN apt-get update && \
    apt-get install -y \
        ca-certificates \
        wget \
        curl \
        tzdata && \
    rm -rf /var/lib/apt/lists/*

# 下载并解压 OpenList
RUN wget https://github.com/OpenListTeam/OpenList/releases/latest/download/openlist-linux-amd64.tar.gz && \
    tar -zxvf openlist-linux-amd64.tar.gz && \
    chmod +x ./openlist && \
    rm openlist-linux-amd64.tar.gz

# 暴露端口（根据 OpenList 的默认端口调整）
EXPOSE 8080

# 设置入口点
ENTRYPOINT ["./openlist", "server", "--no-prefix"]

USER 10014
