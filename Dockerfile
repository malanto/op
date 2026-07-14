FROM nikolaik/python-nodejs:python3.13-nodejs22-slim

WORKDIR /app

# 避免交互式安装提示
ENV DEBIAN_FRONTEND=noninteractive

COPY . .

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    libpq-dev \
    gcc \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir uv \
    npm install -g --no-audit --no-fund --no-progress

RUN uv sync --frozen --no-dev --no-install-project

RUN chmod +x /app/start.sh

EXPOSE 8080

ENTRYPOINT ["/app/start.sh"]

USER 10014
