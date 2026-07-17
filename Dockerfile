FROM debian:bookworm-slim

# 避免交互式安装提示
ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl jq tar bash \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY start.sh /appstart.sh
RUN chmod +x /appstart.sh

EXPOSE 5212

ENTRYPOINT ["/app/start.sh"]

USER 10014
