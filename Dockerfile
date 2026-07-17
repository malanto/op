FROM debian:bookworm-slim

# 避免交互式安装提示
ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl jq tar bash \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app/cloudreve

COPY start.sh /app/cloudreve/start.sh
RUN chmod +x /app/cloudreve/start.sh

EXPOSE 5212

ENTRYPOINT ["/app/cloudreve/start.sh"]

USER 10014
