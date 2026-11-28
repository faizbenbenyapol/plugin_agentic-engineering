#!/usr/bin/env bash
# พิมพ์โน้ตของเวอร์ชันหนึ่งออกจากหัวข้อ "ประวัติการเปลี่ยน" ใน README.md
# รับ: $1 = เวอร์ชัน เช่น 0.15.0, $2 = path ของ README (ไม่ใส่ใช้ README.md ที่รากของ repo)
# คืน: เนื้อหาใต้หัวข้อ "### <เวอร์ชัน>" จนถึงหัวข้อถัดไป ทาง stdout
#      exit 1 ถ้าไม่มีหัวข้อนั้นหรือหัวข้อว่าง เพื่อให้ CI กันการออก release ที่ไม่มีโน้ต
set -euo pipefail

version=${1:?ใช้: scripts/release-notes.sh <เวอร์ชัน> [README.md]}
readme=${2:-"$(cd "$(dirname "$0")/.." && pwd)/README.md"}

# เก็บบรรทัดหลังหัวข้อของเวอร์ชันนี้ หยุดเมื่อเจอหัวข้อระดับ ## หรือ ### ถัดไป
notes=$(awk -v v="$version" '
  $0 == "### " v { on = 1; next }
  on && /^##/ { exit }
  on { print }
' "$readme")

# ตัดบรรทัดว่างหัวท้าย แล้วเช็กว่ายังมีเนื้อหา
notes=$(printf '%s\n' "$notes" | sed -e '/./,$!d' | tac | sed -e '/./,$!d' | tac)
if [ -z "$notes" ]; then
  echo "ไม่พบโน้ตของ $version ใน $readme ต้องมีหัวข้อ '### $version' ใต้ '## ประวัติการเปลี่ยน'" >&2
  exit 1
fi
printf '%s\n' "$notes"
