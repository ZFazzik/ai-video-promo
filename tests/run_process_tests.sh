#!/usr/bin/env bash
# Menjalankan uji proses P01-P08 dengan klip sintetis. Tidak menyentuh file lain.
# Pemakaian: bash tests/run_process_tests.sh <endcard.mp4>
export LC_ALL=C
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
CARD="${1:?Pemakaian: run_process_tests.sh <endcard.mp4>}"
W="$(mktemp -d)"; PASS=0; FAIL=0
ok() { echo "[lulus]  $1"; PASS=$((PASS+1)); }
no() { echo "[GAGAL]  $1 :: $2"; FAIL=$((FAIL+1)); }
# gen <nama> <ukuran> <fps> <durasi> <audio 1|0>
gen() {
  local a=(-f lavfi -i "testsrc2=size=$2:rate=$3:duration=$4")
  local c=(-c:v libx264 -pix_fmt yuv420p)
  if [ "$5" = 1 ]; then a+=(-f lavfi -i "sine=frequency=440:sample_rate=44100:duration=$4"); c+=(-c:a aac -shortest); fi
  ffmpeg -v error "${a[@]}" "${c[@]}" -y "$W/$1.mp4"
}
run() { bash "$HERE/scripts/append_endcard.sh" "$W/$1.mp4" "$CARD" "$W/out/$1__promo.mp4" >"$W/$1.run" 2>&1; }
vf()  { bash "$HERE/scripts/verify_final.sh" "$W/out/$1__promo.mp4" "$W/$1.mp4" "$CARD" "$W/frames/$1" 2>&1; }
dur() { ffprobe -v error -show_entries format=duration -of csv=p=0 "$1"; }
fps() { ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$1"; }

gen c30 1080x1920 30 10 1; gen cna 1080x1920 30 10 0; gen cland 1920x1080 25 10 1
gen c25 1080x1920 25 10 1; gen c60 1080x1920 60 10 1; gen c7 1080x1920 30 7 1; gen c31 1080x1920 30 31 1

# P01 happy path + asli tidak berubah
H0="$(sha256sum "$W/c30.mp4" | cut -d' ' -f1)"
if run c30 && R="$(vf c30)" && echo "$R" | grep -q "STATUS: berhasil" && [ "$(sha256sum "$W/c30.mp4" | cut -d' ' -f1)" = "$H0" ]; then ok "P01 happy path (30 fps, ada audio): berhasil, file asli utuh"; else no "P01" "$(cat "$W/c30.run"; echo "$R")"; fi
# P05 posisi end card (bagian dari verify_final pada P01)
echo "$R" | grep -q "lulus\] frame akhir" && echo "$R" | grep -q "lulus\] frame awal" && ok "P05 end card di akhir, klip di awal (SSIM)" || no "P05" "$R"
# P02 tanpa audio
if run cna && R="$(vf cna)" && echo "$R" | grep -q "STATUS: berhasil"; then ok "P02 klip tanpa audio: audio senyap dibuat, berhasil"; else no "P02" "$(cat "$W/cna.run"; echo "$R")"; fi
# P03 landscape
if run cland && R="$(vf cland)" && echo "$R" | grep -q "lulus\] resolusi 1080x1920"; then ok "P03 klip 1920x1080 dinormalisasi ke 1080x1920 (pad); verify memberi status: $(echo "$R" | tail -1)"; else no "P03" "$(cat "$W/cland.run"; echo "$R")"; fi
# P04 fps 25 dan 60 -> 25
RES=""; for c in c25 c60; do run $c && RES="$RES $(fps "$W/out/${c}__promo.mp4")"; done
if [ "$RES" = " 25/1 25/1" ]; then ok "P04 fps 25 dan 60 keduanya jadi 25 fps"; else no "P04" "fps hasil:$RES"; fi
# P06 file korup
head -c 1024 /dev/urandom > "$W/rusak.mp4"
if ! bash "$HERE/scripts/append_endcard.sh" "$W/rusak.mp4" "$CARD" "$W/out/rusak__promo.mp4" >"$W/rusak.run" 2>&1 && [ ! -f "$W/out/rusak__promo.mp4" ]; then ok "P06 file korup: gagal dengan pesan jelas ($(head -1 "$W/rusak.run"))"; else no "P06" "$(cat "$W/rusak.run")"; fi
# P07 aset end card hilang
if ! bash "$HERE/scripts/append_endcard.sh" "$W/c30.mp4" "$W/tidak-ada.mp4" "$W/out/p7__promo.mp4" >"$W/p7.run" 2>&1 && [ ! -f "$W/out/p7__promo.mp4" ]; then ok "P07 aset hilang: gagal ($(head -1 "$W/p7.run"))"; else no "P07" "$(cat "$W/p7.run")"; fi
# P08 durasi 7 dan 31 dtk
D="$(dur "$CARD")"; GOOD=1
for c in c7 c31; do run $c; X="$(awk -v f="$(dur "$W/out/${c}__promo.mp4")" -v c="$(dur "$W/$c.mp4")" -v e="$D" 'BEGIN{d=f-c-e; if(d<0)d=-d; print (d<=0.3)?1:0}')"; [ "$X" = 1 ] || GOOD=0; done
[ "$GOOD" = 1 ] && ok "P08 durasi hasil = klip + end card (±0,3 dtk) untuk 7 dan 31 dtk" || no "P08" "selisih durasi > 0,3"
echo "----"; echo "Lulus: $PASS  Gagal: $FAIL  (folder kerja: $W)"
[ "$FAIL" = 0 ]
