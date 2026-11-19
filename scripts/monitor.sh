cat > scripts/monitor.sh << 'EOF'
#!/usr/bin/env bash
# Modul 1 - Monitoring service dan kapasitas penyimpanan.
# Exit: 0 sehat | 1 argumen salah | 2 service tidak aktif | 3 disk melebihi batas
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE="monitor"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

SERVICE="ssh"
THRESHOLD=80
TARGET_PATH=""

usage() {
  echo "Penggunaan: $0 -p <direktori> [-s <service>] [-t <batas_persen>]"
  echo "  -p  direktori yang dicek kapasitas disknya (wajib)"
  echo "  -s  nama service systemd yang dicek (default: ssh)"
  echo "  -t  batas pemakaian disk dalam persen, 1-100 (default: 80)"
}

check_service() {
  local svc="$1"
  if ! command -v systemctl >/dev/null 2>&1; then
    log_error "systemctl tidak tersedia, service '$svc' tidak dapat diperiksa"
    return "$EXIT_SERVICE"
  fi
  if systemctl is-active --quiet "$svc"; then
    log_info "Service '$svc' berstatus aktif"
    return 0
  fi
  log_error "Service '$svc' TIDAK aktif atau tidak ditemukan"
  return "$EXIT_SERVICE"
}

check_disk() {
  local path="$1" limit="$2" used
  used="$(df -P "$path" | awk 'NR==2 {gsub("%","",$5); print $5}')"
  if ! [[ "$used" =~ ^[0-9]+$ ]]; then
    log_error "Gagal membaca kapasitas disk untuk '$path'"
    return "$EXIT_DISK"
  fi
  log_info "Pemakaian disk '$path' = ${used}% (batas ${limit}%)"
  if [ "$used" -ge "$limit" ]; then
    log_error "Pemakaian disk ${used}% mencapai/melebihi batas ${limit}%"
    return "$EXIT_DISK"
  fi
  return 0
}

main() {
  while getopts ":p:s:t:h" opt; do
    case "$opt" in
      p) TARGET_PATH="$OPTARG" ;;
      s) SERVICE="$OPTARG" ;;
      t) THRESHOLD="$OPTARG" ;;
      h) usage; exit 0 ;;
      *) usage >&2; exit "$EXIT_USAGE" ;;
    esac
  done

  if [ -z "$TARGET_PATH" ]; then
    log_error "Opsi -p wajib diisi"; usage >&2; exit "$EXIT_USAGE"
  fi
  if [ ! -d "$TARGET_PATH" ]; then
    log_error "Direktori '$TARGET_PATH' tidak ditemukan"; exit "$EXIT_USAGE"
  fi
  if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || [ "$THRESHOLD" -lt 1 ] || [ "$THRESHOLD" -gt 100 ]; then
    log_error "Batas (-t) harus angka 1-100"; exit "$EXIT_USAGE"
  fi

  local rc_service=0 rc_disk=0
  check_service "$SERVICE" || rc_service=$?
  check_disk "$TARGET_PATH" "$THRESHOLD" || rc_disk=$?

  if [ "$rc_service" -ne 0 ]; then
    log_error "STATUS: TIDAK SEHAT (layanan)"; exit "$rc_service"
  fi
  if [ "$rc_disk" -ne 0 ]; then
    log_error "STATUS: TIDAK SEHAT (disk)"; exit "$rc_disk"
  fi
  log_info "STATUS: SEHAT - backup boleh dilanjutkan"
  exit "$EXIT_OK"
}

main "$@"
EOF
