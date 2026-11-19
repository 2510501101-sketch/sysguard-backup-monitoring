# Backup dan Monitoring Layanan Linux

## Identitas Kelompok

Pilihan Proyek: A - Backup dan Monitoring Layanan

Anggota:
1. Putri Diandra Maharani (2510501101)
2. Chavia Vebby Setiawan (2510501102)
3. Siti Sarah Nur Azizah (2510501122)
4. Rizskya Anis (2510501136)

## 1. Deskripsi Proyek

Proyek ini mengembangkan sistem otomasi monitoring layanan dan kapasitas penyimpanan yang terintegrasi dengan proses backup dan restore menggunakan Bash dan Docker.

## 2. Tujuan

- Memeriksa status layanan.
- Memantau kapasitas penyimpanan.
- Menolak backup ketika kondisi tidak memenuhi syarat.
- Membuat arsip backup.
- Memverifikasi integritas arsip.
- Memulihkan dan memverifikasi data.

## 3. Teknologi

- Ubuntu WSL 2
- Bash
- Docker
- Docker Compose
- SSH/SCP
- SHA-256
- Git dan GitHub

## 4. Arsitektur

Host:
- Monitoring
- Integrasi
- Data simulasi
- Log
- Backup dan restore storage

Container:
- Demo service Nginx
- Backup runner

## 5. Instalasi

1. Install Ubuntu WSL 2.
2. Install Docker Desktop.
3. Aktifkan WSL Integration.
4. Clone repository.
5. Buat konfigurasi .env.
6. Build Docker image.

## 6. Menjalankan Proyek

Build image:

docker compose build backup-runner

Menjalankan layanan:

docker compose up -d demo-service

Menjalankan monitoring:

./scripts/monitor.sh

Menjalankan backup:

./scripts/run_backup.sh

## 7. Restore

Jalankan perintah berikut dengan nama arsip yang tersedia:

docker compose run --rm backup-runner /app/scripts/restore.sh NAMA-ARSIP.tar.gz

## 8. Monitoring

docker ps

docker stats --no-stream

cat logs/monitor.log

## 9. Pengujian

- Monitoring berhasil
- Monitoring gagal
- Backup berhasil
- Backup gagal
- Restore berhasil
- Restore gagal
- Integrasi monitoring dan backup
- Pengujian SSH/SCP
- Pengujian persistensi
- Pengujian resource limit
- Pengujian read-only source

## 10. Cleanup

docker compose down

## 11. Rollback

Gunakan arsip backup yang sudah dibuat dan jalankan script restore.sh.

## 12. Keterbatasan

- Monitoring menggunakan layanan simulasi.
- Ambang kapasitas disk masih berbasis konfigurasi.
- SSH diuji menggunakan koneksi lokal WSL.
- Belum menggunakan dashboard monitoring grafis.

## 13. Kontribusi Anggota

Lihat docs/Kontribusi-Anggota.md.
