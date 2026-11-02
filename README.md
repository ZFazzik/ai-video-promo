# ai-video-promo

Skill Hermes untuk Eudeka: membaca isi klip hasil `video-clipping`, memilih satu sorotan layanan Eudeka yang paling nyambung, lalu menempelkan end card animasi di akhir klip.

**Status: v0.5.0, belum diuji pada Hermes sungguhan.** Cabang `uji` dipakai untuk pengujian. Cabang `main` diisi setelah pengujian selesai.

## Isi repo

| Path | Fungsi |
|---|---|
| `SKILL.md` | Instruksi skill (dibaca Hermes) |
| `references/promo-catalog.md` | Katalog sorotan, teks resmi, dan hook A/B |
| `assets/animasi/` | 11 end card MP4 (1080×1920, 25 fps, 15 detik, tanpa audio; dengan logo dan blok kontak) |
| `assets/ASET-DIBUTUHKAN.md` | Daftar file animasi yang harus ada |
| `scripts/append_endcard.sh` | Menempelkan end card ke klip (FFmpeg) |
| `scripts/verify_final.sh` | Verifikasi video final |
| `tests/test-cases.csv` | Kasus uji logika (L) dan proses (P) |
| `tests/run_process_tests.sh` | Uji otomatis P01-P08 |
| `CHANGELOG.md` | Riwayat versi |

## Pasang di Hermes

```bash
cd /home/eudeka/.hermes/skills/media
git clone -b uji <URL-REPO> ai-video-promo
```

Nama folder harus `ai-video-promo` agar sesuai dengan path di bagian "Konfigurasi lokal" pada `SKILL.md`. Path khusus mesin ada di bagian itu; ubah di sana bila lokasinya berbeda.

Kebutuhan: `ffmpeg` dan `ffprobe` (dengan `libx264` dan `aac`), `bash`, skill `video-clipping` (Clipping Studio).

## Uji

```bash
cd /home/eudeka/.hermes/skills/media/ai-video-promo
bash tests/run_process_tests.sh assets/animasi/workspace-a.mp4
```

Uji logika (L01-L29) dijalankan lewat percakapan dengan AI assistant; kasusnya ada di `tests/test-cases.csv`.

## Animasi

File di `assets/animasi/` dirender dari proyek Remotion `eudeka-endcards` (di luar repo ini). Mengubah teks, hook, logo, atau blok kontak berarti memperbarui `promo-catalog.md` dan render ulang animasinya. Durasi end card ikut menentukan Tahap 4 dan Tahap 6 di `SKILL.md`; bila durasi atau linimasa berubah, perbarui juga angka di sana.

## Catatan

- Skill ini hanya membaca dari folder Clipping Studio dan menulis ke `/home/eudeka/promo-output`.
- Tidak ada API key, token, atau ID kanal di repo ini. Jangan memasukkan isi skill `video-clipping` ke sini.
