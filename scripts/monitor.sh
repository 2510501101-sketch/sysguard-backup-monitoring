#!/bin/bash

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/monitor.log"

SERVICE_CONTAINER="backupmon-demo-service"

MAX_DISK_PERCENT="${MAX_DISK_PERCENT:-90}"
MIN_FREE_MB="${MIN_FREE_MB:-100}"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "MONITORING DIMULAI"

# Pemeriksaan Docker
if ! command -v docker >/dev/null 2>&1; then
    log "ERROR: Docker tidak ditemukan"
    exit 1
fi

# Pemeriksaan layanan
SERVICE_STATUS="false"

if docker inspect "$SERVICE_CONTAINER" >/dev/null 2>&1; then
    SERVICE_STATUS=$(docker inspect \
        --format '{{.State.Running}}' "$SERVICE_CONTAINER")
fi

if [ "$SERVICE_STATUS" != "true" ]; then
    log "ERROR: Layanan tidak berjalan"
    exit 1
fi

log "INFO: Layanan berjalan normal"

# Pemeriksaan kapasitas disk
DISK_INFO=$(df -P "$PROJECT_DIR" | awk 'NR==2 {
    gsub("%","",$5);
    print $5 "|" $4
}')

DISK_USED=$(echo "$DISK_INFO" | cut -d'|' -f1)
DISK_FREE_KB=$(echo "$DISK_INFO" | cut -d'|' -f2)

DISK_FREE_MB=$((DISK_FREE_KB / 1024))

log "INFO: Penggunaan disk ${DISK_USED}%"
log "INFO: Ruang kosong ${DISK_FREE_MB} MB"

if [ "$DISK_USED" -ge "$MAX_DISK_PERCENT" ] || \
   [ "$DISK_FREE_MB" -lt "$MIN_FREE_MB" ]; then

    log "WARNING: Kapasitas penyimpanan tidak memenuhi batas"
    exit 1
fi

log "SUCCESS: Kondisi sistem memenuhi syarat backup"
exit 0
