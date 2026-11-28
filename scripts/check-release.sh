#!/usr/bin/env bash
# ตรวจกฎการออกเวอร์ชันก่อน merge (CI รันใน PR และรันเองในเครื่องได้)
# รับ: $1 = ref ที่จะเทียบ เช่น origin/main (ไม่ใส่ใช้ origin/main)
# กฎ:
#   1. version ใน plugin.json เป็นรูป X.Y.Z
#   2. ถ้าแก้ไฟล์ของปลั๊กอิน (.claude-plugin agents hooks skills) ต้องขยับ version ให้มากกว่าของ ref
#   3. ทุกเวอร์ชันต้องมีโน้ตใน README หัวข้อ "### X.Y.Z" (ใช้เป็นโน้ต release)
#   4. หัวของ SKILL.md ต้องเป็น "(vX.Y" ตรงกับ version
#   5. version ใหม่ต้องยังไม่มี tag vX.Y.Z (กันออกเลขซ้ำ)
#   6. references/agents.md ต้องตรงกับ agents/*.md
# คืน: exit 0 เมื่อผ่านทุกข้อ, exit 1 พร้อมรายการข้อที่ไม่ผ่าน
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
base=${1:-origin/main}
cd "$root"
fail=0
bad() { echo "❌ $*"; fail=1; }
ok() { echo "✅ $*"; }

version=$(jq -r .version .claude-plugin/plugin.json)
base_version=$(git show "$base:.claude-plugin/plugin.json" | jq -r .version)

# 1. รูปแบบเลขเวอร์ชัน
if [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then ok "version $version"; else bad "version '$version' ต้องเป็นรูป X.Y.Z"; fi

# 2. แก้ปลั๊กอินแล้วต้องขยับเวอร์ชัน (sort -V เทียบแบบ semver)
changed=$(git diff --name-only "$base"...HEAD -- .claude-plugin agents hooks skills || true)
newer=$(printf '%s\n%s\n' "$base_version" "$version" | sort -V | tail -1)
if [ "$version" != "$base_version" ]; then
  if [ "$newer" = "$version" ]; then ok "ขยับเวอร์ชัน $base_version → $version"; else bad "version $version ต่ำกว่า $base_version ของ $base"; fi
elif [ -n "$changed" ]; then
  bad "แก้ไฟล์ปลั๊กอินแต่ยังเป็น $version เท่ากับ $base ให้ขยับ version ใน .claude-plugin/plugin.json ไฟล์ที่แก้:"
  printf '   %s\n' $changed
else
  ok "ไม่ได้แก้ไฟล์ปลั๊กอิน ไม่ต้องขยับเวอร์ชัน"
fi

# 3. มีโน้ตใน README
if scripts/release-notes.sh "$version" >/dev/null 2>&1; then ok "มีโน้ต ### $version ใน README"; else bad "เพิ่มหัวข้อ '### $version' ใต้ '## ประวัติการเปลี่ยน' ใน README.md"; fi

# 4. หัว SKILL.md ตรงกับเวอร์ชัน
short=${version%.*}
if grep -q "(v$short " skills/agentic-engineering/SKILL.md; then ok "SKILL.md เป็น v$short"; else bad "หัวของ skills/agentic-engineering/SKILL.md ต้องมี '(v$short '"; fi

# 5. เลขใหม่ต้องยังไม่ถูกใช้เป็น tag
if [ "$version" != "$base_version" ]; then
  if git ls-remote --exit-code --tags origin "refs/tags/v$version" >/dev/null 2>&1; then bad "tag v$version มีอยู่แล้ว ให้ใช้เลขใหม่"; else ok "ยังไม่มี tag v$version"; fi
fi

# 6. agents.md ซิงก์กับ agents/*.md
if scripts/sync-agents.sh --check >/dev/null 2>&1; then ok "references/agents.md ตรงกับ agents/"; else bad "รัน scripts/sync-agents.sh แล้ว commit references/agents.md"; fi

exit $fail
