#!/usr/bin/env bash
# Verifikasi mekanis video final (Tahap 6). Hasil tiap butir: lulus / GAGAL / perlu pemeriksaan manual.
# Pemakaian: verify_final.sh <final.mp4> <klip.mp4> <endcard.mp4> [folder_frame]
# Frame awal dan akhir disimpan ke folder_frame (first.png, last.png) agar bisa dilihat/dianalisis.
set -u
[ "$#" -ge 3 ] || { echo "Pemakaian: $0 <final.mp4> <klip.mp4> <endcard.mp4> [folder_frame]" >&2; exit 2; }
FINAL="$1"; CLIP="$2"; CARD="$3"; FR="${4:-$(dirname "$FINAL")/frames}"
mkdir -p "$FR"
BAD=0; MANUAL=0
r() { echo "[$1] $2"; case "$1" in GAGAL) BAD=1;; "perlu pemeriksaan manual") MANUAL=1;; esac; }
dur() { ffprobe -v error -show_entries format=duration -of csv=p=0 "$1" 2>/dev/null; }
ssim() { ffmpeg -hide_banner -v info -i "$1" -i "$2" -lavfi "[0:v]scale=360:640[a];[1:v]scale=360:640[b];[a][b]ssim" -f null - 2>&1 | sed -n 's/.*All:\([0-9.]*\).*/\1/p' | tail -1; }

[ -f "$FINAL" ] || { r GAGAL "file final tidak ada: $FINAL"; echo "STATUS: gagal"; exit 1; }

# 1. decode tanpa error
ERR="$(ffmpeg -v error -i "$FINAL" -f null - 2>&1 || true)"
if [ -z "$ERR" ]; then r lulus "decode tanpa error"; else r GAGAL "decode error: $(echo "$ERR" | head -1)"; fi

# 2. 1080x1920 dengan stream video dan audio
WH="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$FINAL" 2>/dev/null)"
HA="$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$FINAL" 2>/dev/null)"
if [ "$WH" = "1080x1920" ] && [ -n "$HA" ]; then r lulus "resolusi $WH, ada stream video dan audio"; else r GAGAL "resolusi=$WH audio='${HA:-tidak ada}'"; fi

# 3. durasi = klip + end card (±0,3 dtk)
DF="$(dur "$FINAL")"; DC="$(dur "$CLIP")"; DE="$(dur "$CARD")"
SEL="$(awk -v f="$DF" -v c="$DC" -v e="$DE" 'BEGIN{d=f-(c+e); if(d<0)d=-d; printf "%.2f", d}')"
if awk -v s="$SEL" 'BEGIN{exit !(s<=0.3)}'; then r lulus "durasi ${DF}s = klip ${DC}s + end card ${DE}s (selisih ${SEL}s)"; else r GAGAL "durasi ${DF}s, diharapkan ${DC}+${DE}s (selisih ${SEL}s)"; fi

# 4. frame 1 detik terakhir = end card
TF="$(awk -v d="$DF" 'BEGIN{printf "%.2f", d-1.0}')"; TE="$(awk -v d="$DE" 'BEGIN{printf "%.2f", d-1.0}')"
ffmpeg -v error -ss "$TF" -i "$FINAL" -frames:v 1 -y "$FR/last.png" 2>/dev/null
ffmpeg -v error -ss "$TE" -i "$CARD"  -frames:v 1 -y "$FR/card_ref.png" 2>/dev/null
S="$(ssim "$FR/last.png" "$FR/card_ref.png")"
if [ -n "$S" ] && awk -v s="$S" 'BEGIN{exit !(s>=0.95)}'; then r lulus "frame akhir cocok dengan end card (SSIM $S)"; else r "perlu pemeriksaan manual" "frame akhir vs end card SSIM=${S:-?}; lihat $FR/last.png"; fi

# 5. frame detik awal = klip utama
ffmpeg -v error -ss 0.5 -i "$FINAL" -frames:v 1 -y "$FR/first.png" 2>/dev/null
CW="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$CLIP" 2>/dev/null)"
if [ "$CW" = "1080x1920" ]; then
  ffmpeg -v error -ss 0.5 -i "$CLIP" -frames:v 1 -y "$FR/clip_ref.png" 2>/dev/null
  S="$(ssim "$FR/first.png" "$FR/clip_ref.png")"
  if [ -n "$S" ] && awk -v s="$S" 'BEGIN{exit !(s>=0.90)}'; then r lulus "frame awal cocok dengan klip (SSIM $S)"; else r "perlu pemeriksaan manual" "frame awal vs klip SSIM=${S:-?}; lihat $FR/first.png"; fi
else
  r "perlu pemeriksaan manual" "klip sumber $CW (bukan 9:16, diberi pad); lihat $FR/first.png"
fi

if [ "$BAD" = 1 ]; then echo "STATUS: gagal"; exit 1
elif [ "$MANUAL" = 1 ]; then echo "STATUS: perlu pemeriksaan manual"; exit 0
else echo "STATUS: berhasil"; exit 0; fi
