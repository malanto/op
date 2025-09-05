FROM alpine:latest

# 设置工作目录
WORKDIR /opt/openlist

# 安装必要的工具
RUN apk add --no-cache ca-certificates wget curl

# 下载并解压 OpenList
RUN wget https://github.com/OpenListTeam/OpenList/releases/latest/download/openlist-linux-amd64.tar.gz && \
    tar -zxvf openlist-linux-amd64.tar.gz && \
    chmod +x ./openlist && \
    rm openlist-linux-amd64.tar.gz

# 复制数据目录
COPY data ./data

# 暴露端口（根据 OpenList 的默认端口调整）
EXPOSE 8080

# 设置入口点
ENTRYPOINT ["./openlist", "server", "--no-prefix"]

USER 10014
