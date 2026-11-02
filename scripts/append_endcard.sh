#!/usr/bin/env bash
# Menempelkan end card di AKHIR klip. Klip asli tidak diubah (hasil selalu file baru).
# Pemakaian: append_endcard.sh <klip.mp4> <endcard.mp4> <output.mp4>
# Log lengkap ditulis ke <output>.log. Kode keluar 0 hanya jika output valid terbentuk.
set -euo pipefail

die() { echo "GAGAL: $*" >&2; exit 1; }

[ "$#" -eq 3 ] || { echo "Pemakaian: $0 <klip.mp4> <endcard.mp4> <output.mp4>" >&2; exit 2; }
CLIP="$1"; CARD="$2"; OUT="$3"
LOG="${OUT%.mp4}.log"
TMP="${OUT%.mp4}.tmp.mp4"

command -v ffmpeg  >/dev/null || die "ffmpeg tidak ditemukan"
command -v ffprobe >/dev/null || die "ffprobe tidak ditemukan"
[ -f "$CLIP" ] || die "klip tidak ada: $CLIP"
[ -f "$CARD" ] || die "aset end card tidak ada: $CARD"
[ "$(realpath "$CLIP")" != "$(realpath -m "$OUT")" ] || die "output tidak boleh sama dengan klip asli"
[ "$(realpath "$CARD")" != "$(realpath -m "$OUT")" ] || die "output tidak boleh sama dengan aset end card"

has_video() { [ -n "$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of csv=p=0 "$1" 2>/dev/null || true)" ]; }
has_audio() { [ -n "$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$1" 2>/dev/null || true)" ]; }
dur()       { ffprobe -v error -show_entries format=duration -of csv=p=0 "$1" 2>/dev/null; }

# Tahap 1: klip dan end card harus bisa dibuka dan punya stream video
has_video "$CLIP" || die "klip tidak bisa dibuka atau tidak punya stream video (rusak?): $CLIP"
has_video "$CARD" || die "aset end card tidak bisa dibuka atau tidak punya stream video: $CARD"
D0="$(dur "$CLIP")"; D1="$(dur "$CARD")"
[ -n "$D0" ] && [ -n "$D1" ] || die "durasi tidak terbaca"

mkdir -p "$(dirname "$OUT")"
: > "$LOG"
rm -f "$TMP" "$OUT"

# Sumber audio: pakai audio asli bila ada, bila tidak buat audio senyap (supaya concat tidak gagal)
INPUTS=(-i "$CLIP" -i "$CARD")
NEXT=2
if has_audio "$CLIP"; then A0="[0:a]"; else
  INPUTS+=(-f lavfi -t "$D0" -i "anullsrc=r=48000:cl=stereo"); A0="[$NEXT:a]"; NEXT=$((NEXT+1)); fi
if has_audio "$CARD"; then A1="[1:a]"; else
  INPUTS+=(-f lavfi -t "$D1" -i "anullsrc=r=48000:cl=stereo"); A1="[$NEXT:a]"; NEXT=$((NEXT+1)); fi

VF="scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1,fps=25,format=yuv420p,setpts=PTS-STARTPTS"
AF="aresample=48000,aformat=sample_fmts=fltp:channel_layouts=stereo,asetpts=PTS-STARTPTS"
FILTER="[0:v]${VF}[v0];[1:v]${VF}[v1];${A0}${AF}[a0];${A1}${AF}[a1];[v0][a0][v1][a1]concat=n=2:v=1:a=1[v][a]"

CMD=(ffmpeg -hide_banner -v error -stats_period 5 "${INPUTS[@]}" -filter_complex "$FILTER" -map "[v]" -map "[a]"
     -c:v libx264 -preset "${PROMO_PRESET:-medium}" -crf 18 -pix_fmt yuv420p -r 25
     -c:a aac -b:a 192k -ar 48000 -ac 2 -movflags +faststart -y "$TMP")
{ echo "# $(date -Is)"; printf '%q ' "${CMD[@]}"; echo; } >> "$LOG"

if ! "${CMD[@]}" >> "$LOG" 2>&1; then
  rm -f "$TMP"; die "FFmpeg gagal. Lihat log: $LOG"
fi
has_video "$TMP" || { rm -f "$TMP"; die "output tidak valid. Lihat log: $LOG"; }
mv "$TMP" "$OUT"
echo "OK: $OUT (klip ${D0}s + end card ${D1}s). Log: $LOG"
