
#!/bin/bash

set -Eeuo pipefail

SOURCE_DIR="/data/source"
BACKUP_DIR="/data/backups"
LOG_FILE="/app/logs/backup.log"

mkdir -p "$BACKUP_DIR" "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" \
    | tee -a "$LOG_FILE"
}

log "BACKUP DIMULAI"

# Validasi sumber
if [ ! -d "$SOURCE_DIR" ]; then
    log "ERROR: Direktori sumber tidak ditemukan"
    exit 1
fi

if [ -z "$(find "$SOURCE_DIR" -type f -print -quit)" ]; then
    log "ERROR: Direktori sumber kosong"
    exit 1
fi

# Validasi tujuan
if [ ! -d "$BACKUP_DIR" ] || [ ! -w "$BACKUP_DIR" ]; then
    log "ERROR: Direktori tujuan tidak dapat ditulis"
    exit 1
fi

TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
BASE="backup-$TIMESTAMP"

ARCHIVE="$BACKUP_DIR/$BASE.tar.gz"
MANIFEST="$BACKUP_DIR/$BASE.manifest"
CHECKSUM="$ARCHIVE.sha256"

# Membuat arsip
tar -czf "$ARCHIVE" -C "$SOURCE_DIR" .

# Membuat manifest isi file
(
    cd "$SOURCE_DIR"
    find . -type f -print0 | sort -z | xargs -0 sha256sum
) > "$MANIFEST"

# Membuat checksum arsip
(
    cd "$BACKUP_DIR"
    sha256sum "$(basename "$ARCHIVE")" \
    > "$(basename "$CHECKSUM")"
)

log "SUCCESS: Backup berhasil dibuat"
log "INFO: Arsip $ARCHIVE"
log "INFO: Checksum $CHECKSUM"
log "INFO: Manifest $MANIFEST"

exit 0
