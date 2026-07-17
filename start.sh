#!/usr/bin/env bash
set -euo pipefail

# =========================
# 路径
# =========================
WORKDIR="${WORKDIR:-/app/cloudreve}"
DATA_DIR="${DATA_DIR:-${WORKDIR}/data}"
BIN_PATH="${BIN_PATH:-${WORKDIR}/cloudreve}"
CONF_PATH="${CONF_PATH:-${DATA_DIR}/conf.ini}"

mkdir -p "$WORKDIR" "$DATA_DIR"
cd "$WORKDIR"

log() { echo "[entrypoint] $*"; }

# =========================
# 下载 Cloudreve
# =========================
ARCH="${ARCH:-amd64}"   # linux_amd64 / linux_arm64
OS="${OS:-linux}"

DOWNLOAD_ENABLED="${DOWNLOAD_ENABLED:-true}"
DOWNLOAD_POLICY="${DOWNLOAD_POLICY:-if-missing}" 
# if-missing: 二进制不存在才下载（默认）
# always: 每次启动都下载覆盖（不建议生产）

CLOUDREVE_VERSION="${CLOUDREVE_VERSION:-}" # 留空 = latest

get_latest_version() {
  curl -fsSL "https://api.github.com/repos/cloudreve/Cloudreve/releases/latest" \
    | jq -r '.tag_name'
}

download_cloudreve() {
  local ver="$1"

  if [[ -z "$ver" || "$ver" == "null" ]]; then
    log "ERROR: 无法获取 Cloudreve 版本号"
    exit 1
  fi

  local url="https://github.com/cloudreve/Cloudreve/releases/download/${ver}/cloudreve_${ver}_${OS}_${ARCH}.tar.gz"
  log "Downloading Cloudreve ${ver} from: ${url}"

  rm -f cloudreve.tar.gz
  curl -fL "$url" -o cloudreve.tar.gz

  tar -zxf cloudreve.tar.gz
  rm -f cloudreve.tar.gz LICENSE README.md README_zh-CN.md 2>/dev/null || true

  chmod +x "$BIN_PATH"
  log "Cloudreve ${ver} ready: $BIN_PATH"
}

if [[ "$DOWNLOAD_ENABLED" == "true" ]]; then
  if [[ "$DOWNLOAD_POLICY" == "always" || ! -f "$BIN_PATH" ]]; then
    if [[ -z "$CLOUDREVE_VERSION" ]]; then
      CLOUDREVE_VERSION="$(get_latest_version)"
    fi
    download_cloudreve "$CLOUDREVE_VERSION"
  else
    log "Binary exists, skip download: $BIN_PATH"
  fi
else
  log "DOWNLOAD_ENABLED=false, skip download"
fi

if [[ ! -x "$BIN_PATH" ]]; then
  log "ERROR: Cloudreve binary not found/executable at $BIN_PATH"
  exit 1
fi

# =========================
# conf.ini 生成策略
# =========================
CONF_POLICY="${CONF_POLICY:-if-missing}"
# if-missing: conf.ini 不存在才生成（推荐）
# overwrite: 每次都生成覆盖（会继承旧 SessionSecret/HashIDSalt，除非 env 指定）

# 从旧 conf.ini 读取 key = value
old_val() {
  local key="$1"
  [[ -f "$CONF_PATH" ]] || return 0
  awk -F'=' -v k="$key" '
    $1 ~ "^[[:space:]]*"k"[[:space:]]*$" {
      v=$2
      sub(/^[[:space:]]+/, "", v)
      sub(/[[:space:]]+$/, "", v)
      print v
      exit
    }' "$CONF_PATH" || true
}

# =========================
# env -> ini
# =========================
SYSTEM_DEBUG="${SYSTEM_DEBUG:-false}"
SYSTEM_MODE="${SYSTEM_MODE:-master}"
SYSTEM_LISTEN="${SYSTEM_LISTEN:-:5212}"

# 如果 env 没提供，则继承旧值；旧值也没有就留空（给 Cloudreve 自己生成的机会）
SESSION_SECRET="${SESSION_SECRET:-$(old_val SessionSecret)}"
HASH_ID_SALT="${HASH_ID_SALT:-$(old_val HashIDSalt)}"

DB_TYPE="${DB_TYPE:-mysql}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-cloudreve}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_NAME="${DB_NAME:-cloudreve}"

REDIS_ENABLED="${REDIS_ENABLED:-false}"
REDIS_NETWORK="${REDIS_NETWORK:-tcp}"
REDIS_SERVER="${REDIS_SERVER:-}"
REDIS_PASSWORD="${REDIS_PASSWORD:-}"
REDIS_DB="${REDIS_DB:-0}"
REDIS_USER="${REDIS_USER:-default}"
REDIS_USE_TLS="${REDIS_USE_TLS:-false}"
REDIS_TLS_SKIP_VERIFY="${REDIS_TLS_SKIP_VERIFY:-false}"

write_conf() {
  log "Generating conf.ini -> $CONF_PATH"

  cat > "$CONF_PATH" <<EOF
[System]
Debug = ${SYSTEM_DEBUG}
Mode = ${SYSTEM_MODE}
Listen = ${SYSTEM_LISTEN}
SessionSecret = ${SESSION_SECRET}
HashIDSalt = ${HASH_ID_SALT}

[Database]
Type = ${DB_TYPE}
Port = ${DB_PORT}
User = ${DB_USER}
Password = ${DB_PASSWORD}
Host = ${DB_HOST}
Name = ${DB_NAME}
EOF

  if [[ "$REDIS_ENABLED" == "true" ]]; then
    cat >> "$CONF_PATH" <<EOF

[Redis]
Network = ${REDIS_NETWORK}
Server = ${REDIS_SERVER}
Password = ${REDIS_PASSWORD}
DB = ${REDIS_DB}
User = ${REDIS_USER}
UseTLS = ${REDIS_USE_TLS}
TLSSkipVerify = ${REDIS_TLS_SKIP_VERIFY}
EOF
  fi
}

if [[ "$CONF_POLICY" == "overwrite" ]]; then
  write_conf
else
  if [[ -f "$CONF_PATH" ]]; then
    log "conf.ini exists, skip generate (CONF_POLICY=if-missing): $CONF_PATH"
  else
    write_conf
  fi
fi

# =========================
# 启动
# =========================
log "Starting Cloudreve..."
exec "$BIN_PATH"
