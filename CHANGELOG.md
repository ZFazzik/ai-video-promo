# Changelog

## v0.4.0
Menutup celah hasil tinjauan v0.3.2 terhadap skill video-clipping nyata dan lingkungan Hermes kantor.
- Input: klip dibaca dari `.srt` Clipping Studio (path dari `./clip show`, hanya baca); `.words.json` sebagai cadangan; metadata AI (`title`, `hook`, `reason`) hanya petunjuk karena sering kosong. Tahap 2 mewaspadai salah eja Whisper dan cue pecahan di awal.
- Path: bagian "Konfigurasi lokal" dengan path absolut (tidak memakai `HERMES_SKILL_DIR`). Output ke `/home/eudeka/promo-output`, di luar `clipping-studio`. Skill tidak mengubah apa pun di folder Clipping Studio.
- End card: animasi jadi dari Remotion di `assets/animasi/` (lima sorotan, hook A/B, paket umum). Tidak ada logo. Cadangan "logo statis + animasi FFmpeg" dan "teks bergaya" dihapus; aset kurang = status `aset kurang`.
- Hook: dua varian per sorotan (A pertanyaan masalah, B ajakan); aturan pemilihan di Tahap 3; ragu = A; S4 hanya A sampai B dikonfirmasi.
- Sorotan pendukung hanya disebut di laporan, tidak tampil di video.
- Definisi "pendidikan" eksplisit; edukasi umum (kesehatan dan sejenisnya) = skor 0.
- Tahap 5: `scripts/append_endcard.sh` (normalisasi ke 1080×1920, 25 fps, yuv420p, AAC 48 kHz stereo; audio senyap bila tidak ada audio; output sementara dipindah hanya bila valid). Tahap 6: `scripts/verify_final.sh` (decode, resolusi, audio, durasi dari `ffprobe` klip, SSIM frame awal dan akhir, simpan frame). Pemeriksaan visual lewat `vision_analyze` bila tersedia.
- fps target diubah dari 30 ke 25 mengikuti klip Clipping Studio.
- End card didesain ulang (lebih premium, berlapis, animasi halus): durasi 6 detik (sebelumnya 5) agar hook terbaca dan footer tampil di akhir; footer kontak resmi tertanam di semua animasi (About Us, Blog, Contact, alamat, email, telepon). Aturan 4 SKILL.md dan katalog diperbarui; QR dan media sosial tetap tidak dipakai.
- Katalog v0.4.0: kolom hook A/B dan nama file animasi; kolom aset logo dihapus.
- Uji: `tests/test-cases.csv` diperbarui (L06, P04 diubah; L20-L28 baru) dan `tests/run_process_tests.sh` menjalankan P01-P08 otomatis.
- Belum berubah: skill belum diuji ke Hermes sungguhan (celah 6); animasi belum disalin ke `assets/animasi/`.

## v0.3.2
Skala relevansi 0-4 plus `tidak-dapat-ditentukan`, aturan skip skor 0, pengaman skip, status `dilewati`.

## v0.3.1
Katalog terverifikasi dari flyer; elemen tak terverifikasi dikeluarkan; format laporan dipadatkan.

## v0.3.0
Skill difokuskan ke tahap pasca-clip; tambah tahap render/gabung/verifikasi; katalog terstruktur.
