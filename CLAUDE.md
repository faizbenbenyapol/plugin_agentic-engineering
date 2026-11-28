# plugin-agentic-engineering

repo นี้คือปลั๊กอิน agentic-engineering สำหรับ Claude Code และแอป Claude คุยกับเจ้าของ repo เป็นภาษาไทย commit ใช้หัวข้ออังกฤษแบบ `type(scope): subject` และ body ภาษาไทย

## คำสั่ง

- ตรวจกฎการออกเวอร์ชัน: `scripts/check-release.sh origin/main`
- ดูโน้ตของเวอร์ชัน: `scripts/release-notes.sh 0.15.0`
- build ไฟล์ติดตั้ง: `scripts/build-plugin.sh` (ได้ `dist/agentic-engineering-vX.Y.Z.plugin`)
- ซิงก์กติกา agent: `scripts/sync-agents.sh`
- ตรวจโครงสร้างปลั๊กอิน: `claude plugin validate .`

## กฎ: ทุกเวอร์ชันต้องมี release

แก้ไฟล์ของปลั๊กอิน (`.claude-plugin/`, `agents/`, `hooks/`, `skills/`) = ออกเวอร์ชันใหม่เสมอ ใน PR เดียวกันต้องทำครบ 3 อย่าง:

1. ขยับ `version` ใน `.claude-plugin/plugin.json` (แก้กติกาหรือเพิ่มของ = ขยับ minor, แก้คำผิดหรือบั๊กเล็ก = ขยับ patch)
2. เขียนหัวข้อ `### X.Y.Z` บนสุดใต้ `## ประวัติการเปลี่ยน` ใน `README.md` ข้อความนี้กลายเป็นโน้ตของ release ตรง ๆ จึงเขียนให้คนติดตั้งอ่านรู้เรื่อง
3. แก้หัว `skills/agentic-engineering/SKILL.md` เป็น `(vX.Y ...)`

แล้ว merge เข้า `main` workflow `release` จะสร้าง tag `vX.Y.Z` ออก GitHub Release และแนบไฟล์ `.plugin` เอง ห้ามสร้าง tag หรือ release ของเวอร์ชันใหม่ด้วยมือ ให้ workflow ทำ จะได้มีแหล่งเดียว

เวอร์ชันเก่าที่ยังไม่มี release ใช้ workflow `backfill` (กด Run workflow ในแท็บ Actions ใส่ `เวอร์ชัน=commit`) มันเช็กว่าเลขใน commit ตรงกันก่อน ข้ามเลขที่มี tag แล้ว และไม่ตั้ง release ย้อนหลังเป็น latest

## สิ่งที่บังคับใช้

| กฎ | บังคับด้วย |
| --- | --- |
| แก้ปลั๊กอินต้องขยับเลข และเลขต้องเพิ่มขึ้น | `scripts/check-release.sh` ใน workflow `check` ทุก PR |
| ทุกเวอร์ชันมีโน้ตใน README | `scripts/check-release.sh` (เรียก `release-notes.sh`) |
| หัว SKILL.md ตรงกับเลข | `scripts/check-release.sh` |
| เลขใหม่ต้องไม่ซ้ำ tag เดิม | `scripts/check-release.sh` และ workflow `release` ข้ามเลขที่มี tag แล้ว |
| `references/agents.md` ตรงกับ `agents/*.md` | `scripts/check-release.sh` (เรียก `sync-agents.sh --check`) |
| merge แล้วได้ release | workflow `release` บน push เข้า `main` |

ถ้า CI ของ PR แดง ให้อ่านบรรทัด ❌ แต่ละบรรทัดบอกว่าต้องแก้อะไร

## ไฟล์ที่ไม่อยู่ในไฟล์ติดตั้ง

`.github/`, `docs/`, `scripts/` และ `CLAUDE.md` เป็นของคนดูแล repo ไม่ถูก zip เข้า `.plugin` (ดู `scripts/build-plugin.sh`) ไฟล์ที่ปลั๊กอินต้องใช้ตอนทำงานต้องอยู่ใน `.claude-plugin/`, `agents/`, `hooks/` หรือ `skills/`
