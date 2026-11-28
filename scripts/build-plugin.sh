#!/usr/bin/env bash
# zip ปลั๊กอินเป็นไฟล์ .plugin ที่แอป Claude เปิดติดตั้งได้
# รับ: $1 = path ไฟล์ปลายทาง (ไม่ใส่ใช้ dist/agentic-engineering-v<เวอร์ชัน>.plugin)
# ใส่เฉพาะไฟล์ที่ปลั๊กอินใช้ตอนทำงาน ไม่ใส่ไฟล์ของคนดูแล repo (.github, docs, scripts, CLAUDE.md)
# คืน: path ของไฟล์ที่สร้าง ทาง stdout
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
version=$(jq -r .version "$root/.claude-plugin/plugin.json")
out=${1:-"$root/dist/agentic-engineering-v$version.plugin"}

mkdir -p "$(dirname "$out")"
out=$(cd "$(dirname "$out")" && pwd)/$(basename "$out")
rm -f "$out"
cd "$root"
zip -qr "$out" .claude-plugin agents hooks skills README.md -x "*.DS_Store"
echo "$out"
