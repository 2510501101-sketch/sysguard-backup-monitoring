
#!/bin/bash

set -Eeuo pipefail

BACKUP_DIR="/data/backups"
RESTORE_ROOT="/data/restore"
LOG_FILE="/app/logs/restore.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" \
    | tee -a "$LOG_FILE"
}

if [ "$#" -ne 1 ]; then
    log "ERROR: Masukkan nama arsip backup"
    exit 1
fi

ARCHIVE_NAME="${1##*/}"

if [[ "$ARCHIVE_NAME" != backup-*.tar.gz ]]; then
    log "ERROR: Nama arsip tidak valid"
    exit 1
fi

ARCHIVE="$BACKUP_DIR/$ARCHIVE_NAME"
CHECKSUM="$ARCHIVE.sha256"

BASE="${ARCHIVE_NAME%.tar.gz}"
MANIFEST="$BACKUP_DIR/$BASE.manifest"

if [ ! -f "$ARCHIVE" ]; then
    log "ERROR: Arsip tidak ditemukan"
    exit 1
fi

if [ ! -f "$CHECKSUM" ] || [ ! -f "$MANIFEST" ]; then
    log "ERROR: Checksum atau manifest tidak ditemukan"
    exit 1
fi

# Verifikasi integritas arsip
if ! (cd "$BACKUP_DIR" && sha256sum -c "$ARCHIVE_NAME.sha256"); then
    log "ERROR: Integritas arsip gagal"
    exit 1
fi

mkdir -p "$RESTORE_ROOT"

RESTORE_DIR="$RESTORE_ROOT/$BASE-restore"

if [ -e "$RESTORE_DIR" ]; then
    log "ERROR: Folder hasil restore sudah tersedia"
    exit 1
fi

mkdir -p "$RESTORE_DIR"

# Ekstraksi arsip
if ! tar -xzf "$ARCHIVE" -C "$RESTORE_DIR"; then
    log "ERROR: Ekstraksi arsip gagal"
    exit 1
fi

# Verifikasi isi hasil restore
if ! (cd "$RESTORE_DIR" && sha256sum -c "$MANIFEST"); then
    log "ERROR: Verifikasi hasil restore gagal"
    exit 1
fi

log "SUCCESS: Restore dan verifikasi berhasil"
log "INFO: Hasil restore $RESTORE_DIR"

exit 0

