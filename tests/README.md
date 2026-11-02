# Pengujian skill ai-video-promo

- `test-cases.csv`: kasus uji logika (L01-L28, dijalankan lewat percakapan dengan AI assistant) dan proses (P01-P08).
- `run_process_tests.sh`: menjalankan P01-P08 otomatis dengan klip sintetis.
  `bash tests/run_process_tests.sh assets/animasi/workspace-a.mp4`
  Opsional `PROMO_PRESET=ultrafast` untuk uji lebih cepat (default `medium`, sama dengan pemakaian nyata).
  Skrip hanya menulis ke folder sementara dan tidak menyentuh file lain.
