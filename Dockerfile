FROM nikolaik/python-nodejs:python3.12-nodejs22-slim

WORKDIR /app

# 避免交互式安装提示
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y git curl \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY . .
RUN chmod +x /start.sh

EXPOSE 8080

ENTRYPOINT ["/app/start.sh"]

USER 10014
