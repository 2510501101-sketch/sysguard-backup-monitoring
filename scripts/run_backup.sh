
#!/bin/bash

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LOG_FILE="$PROJECT_DIR/logs/integration.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" \
    | tee -a "$LOG_FILE"
}

log "INTEGRASI MONITORING DAN BACKUP DIMULAI"

# Jalankan monitoring terlebih dahulu
if ! "$PROJECT_DIR/scripts/monitor.sh"; then
    log "BACKUP DITOLAK: Kondisi sistem tidak memenuhi syarat"
    exit 1
fi

log "MONITORING BERHASIL"

# Jalankan backup melalui Docker
if ! docker compose run --rm backup-runner \
    /app/scripts/backup.sh; then

    log "ERROR: Proses backup gagal"
    exit 1
fi

log "SUCCESS: Integrasi monitoring dan backup berhasil"

exit 0
