#!/usr/bin/env bash
# เตรียมของสำหรับ release ย้อนหลังของเวอร์ชันเก่าหนึ่งตัว (workflow backfill เรียกใช้)
# รับ: $1 = เวอร์ชัน เช่น 0.14.0, $2 = commit ของเวอร์ชันนั้น, $3.. = เวอร์ชันที่รวมอยู่ใน release นี้ด้วย (ไม่มีก็ได้)
# ทำ: เช็กว่า plugin.json ที่ commit นั้นเป็นเลขเดียวกัน, เขียนโน้ตจาก README ปัจจุบันลง dist/notes-<v>.md
#     และ zip ไฟล์ปลั๊กอินของ commit นั้นเป็น dist/agentic-engineering-v<v>.plugin
# คืน: exit 1 ถ้าเลขไม่ตรงหรือไม่มีโน้ต จะได้ไม่ออก release ผิดตัว
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
version=${1:?ใช้: scripts/backfill-prepare.sh <เวอร์ชัน> <commit> [เวอร์ชันที่รวม...]}
commit=${2:?ต้องระบุ commit}
shift 2
cd "$root"

# เลขใน commit นั้นต้องตรงกับเวอร์ชันที่จะ tag
at_commit=$(git show "$commit:.claude-plugin/plugin.json" | jq -r .version)
if [ "$at_commit" != "$version" ]; then
  echo "commit $commit เป็น $at_commit ไม่ใช่ $version" >&2
  exit 1
fi

mkdir -p dist
notes="dist/notes-$version.md"
scripts/release-notes.sh "$version" > "$notes"
for extra in "$@"; do
  printf '\n## รวม %s\n\n' "$extra" >> "$notes"
  scripts/release-notes.sh "$extra" >> "$notes"
done
printf '\n---\nrelease ย้อนหลัง: tag ที่ commit ของเวอร์ชันนี้ ไฟล์ .plugin สร้างจาก commit เดียวกัน\n' >> "$notes"

# zip เฉพาะไฟล์ปลั๊กอินของ commit นั้น (ใช้ git archive จึงไม่แตะ working tree)
src=$(mktemp -d)
git archive "$commit" | tar -x -C "$src"
out="$root/dist/agentic-engineering-v$version.plugin"
rm -f "$out"
(cd "$src" && zip -qr "$out" $(ls -d .claude-plugin agents hooks skills README.md 2>/dev/null) -x "*.DS_Store")
rm -rf "$src"
echo "$out"
