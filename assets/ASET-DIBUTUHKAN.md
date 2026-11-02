# Aset yang dibutuhkan skill ai-video-promo

Semua aset animasi dirender dari proyek Remotion `eudeka-endcards` (`node scripts/render-all.mjs`, revisi 3) lalu disalin ke `assets/animasi/`.
Logo yang tertanam: `eudeka!` (paket umum, S1, S3, S4, S5) dan `Kihajar.id` (S2). Rincian elemen tertanam ada di `references/promo-catalog.md`.

| File | Sorotan / hook | Status |
|---|---|---|
| assets/animasi/umum.mp4 | Paket umum (tanpa hook) | tersedia |
| assets/animasi/lab-ai-turnkey-a.mp4 | S1, hook A | tersedia |
| assets/animasi/lab-ai-turnkey-b.mp4 | S1, hook B | tersedia |
| assets/animasi/kihajar-id-a.mp4 | S2, hook A | tersedia |
| assets/animasi/kihajar-id-b.mp4 | S2, hook B | tersedia |
| assets/animasi/workspace-a.mp4 | S3, hook A | tersedia |
| assets/animasi/workspace-b.mp4 | S3, hook B | tersedia |
| assets/animasi/chromebook-a.mp4 | S4, hook A | tersedia |
| assets/animasi/chromebook-b.mp4 | S4, hook B | tersedia |
| assets/animasi/pelatihan-sertifikasi-a.mp4 | S5, hook A | tersedia |
| assets/animasi/pelatihan-sertifikasi-b.mp4 | S5, hook B | tersedia |
| assets/eudeka-flyer-source.jpeg | sumber teks katalog | belum disalin (hanya sumber teks, tidak dipakai sebagai end card) |

Spesifikasi: MP4 H.264, 1080×1920, 25 fps, 15 detik (375 frame: 2 detik intro logo + 13 detik isi), tanpa audio.

Bila salah satu file di atas tidak ada atau tidak sesuai spesifikasi, skill memberi status `aset kurang` untuk klip yang membutuhkannya (SKILL.md aturan 12).
