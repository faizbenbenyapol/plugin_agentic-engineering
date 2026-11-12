#!/usr/bin/env bash
# เพิ่มหนึ่งแถวลง decision log แบบ TSV (append-only)
# ใช้: log.sh <logfile> <phase> <decision> <why> <evidence> <result>
set -euo pipefail

if [ "$#" -ne 6 ]; then
  echo "usage: log.sh <logfile> <phase> <decision> <why> <evidence> <result>" >&2
  exit 2
fi

logfile=$1
shift
header=$'ts\tphase\tdecision\twhy\tevidence\tresult'

# ทำให้แต่ละช่องอยู่บรรทัดเดียว และกันสูตรของ spreadsheet ทำงานเมื่อเปิด TSV ใน Excel/Sheets
clean() {
  local v=${1//$'\t'/ }
  v=${v//$'\r'/ }
  v=${v//$'\n'/ }
  case $v in [=+@-]*) v="'$v" ;; esac
  printf '%s' "$v"
}

if [ ! -e "$logfile" ]; then
  mkdir -p "$(dirname "$logfile")"
  # สร้างไฟล์พร้อมหัวตารางด้วย ln ซึ่งสำเร็จได้ตัวเดียว หลาย agent เริ่ม log เดียวกันพร้อมกันจึงไม่เขียนทับกัน
  tmp=$(mktemp "$logfile.XXXXXX")
  printf '%s\n' "$header" > "$tmp"
  ln "$tmp" "$logfile" 2>/dev/null || true
  rm -f "$tmp"
fi

if [ ! -s "$logfile" ]; then
  printf '%s\n' "$header" >> "$logfile"
elif [ "$(tail -c1 "$logfile" | od -An -c | tr -d ' ')" != '\n' ]; then
  printf '\n' >> "$logfile"
fi

row=$(date -u +%Y-%m-%dT%H:%M:%SZ)
for cell in "$@"; do
  row+=$'\t'"$(clean "$cell")"
done
printf '%s\n' "$row" >> "$logfile"
