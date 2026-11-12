#!/usr/bin/env bash
# สร้าง skills/agentic-engineering/references/agents.md จาก agents/*.md
# ให้กติกาของแต่ละบทบาทมีแหล่งความจริงเดียว (ใช้ตอนเรียก agent ตามชื่อไม่ได้)
# ใช้: scripts/sync-agents.sh          เขียนไฟล์ใหม่
#      scripts/sync-agents.sh --check  exit 1 ถ้าไฟล์ไม่ตรงกับ agents/*.md
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
out="$root/skills/agentic-engineering/references/agents.md"

render() {
  printf '%s\n\n' '# กติกาของแต่ละบทบาท (ใช้หัว brief เมื่อเรียก agent ตามชื่อไม่ได้)'
  printf '%s\n' 'ไฟล์นี้สร้างจาก `agents/*.md` ที่รากของ plugin ด้วย `scripts/sync-agents.sh` ที่รากของ plugin ห้ามแก้ตรงนี้'
  local found=0 file
  for file in "$root"/agents/*.md; do
    [ -e "$file" ] || continue
    found=1
    printf '\n## %s\n\n' "$(basename "$file" .md)"
    tr -d '\r' < "$file" | awk 'f>=2 {print} /^---$/ {f++}' || return 1
  done
  if [ "$found" -eq 0 ]; then
    echo "ไม่พบ agents/*.md" >&2
    return 1
  fi
}

if [ "${1:-}" = "--check" ]; then
  expected=$(render)
  if ! diff -u "$out" <(printf '%s\n' "$expected"); then
    echo "agents.md ไม่ตรงกับ agents/*.md ให้รัน scripts/sync-agents.sh" >&2
    exit 1
  fi
  echo "agents.md ตรงกับ agents/*.md"
else
  tmp=$(mktemp "$out.XXXXXX")
  if render > "$tmp"; then
    mv "$tmp" "$out"
    echo "เขียน $out แล้ว"
  else
    rm -f "$tmp"
    exit 1
  fi
fi
