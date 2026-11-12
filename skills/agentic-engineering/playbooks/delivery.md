# ส่งมอบ (commit และ PR)

ทำท้ายทุก playbook ที่แก้โค้ด playbook ที่อ่านอย่างเดียวไม่ต้องทำ ระดับเบาทำแค่หัวข้อ Commit

**ค่าเริ่มต้นคือ commit ในเครื่องบน branch งาน** push และเปิด PR เฉพาะเมื่อผู้ใช้ขอ หรือ `CLAUDE.md` ของโปรเจกต์บอกให้ทำ **บนคลาวด์ (`CLAUDE_CODE_REMOTE=true`) ให้ push branch งานก่อนจบ** เพราะ VM ถูกเรียกคืนได้ สิ่งที่ต้องหยุดรอยืนยันดูรายการเดียวใน SKILL.md ข้อ 5 เปิด PR ใช้ `playbooks/pull-request.md`

## Worktree และ branch

- ทำงานบน branch แยกจาก main ไม่แก้บน main ตรง ๆ (ยกเว้นผู้ใช้หรือ repo บอกให้ทำบน main) agent ที่ทำขนานได้ worktree คนละอัน
- branch สกปรกด้วยงานอื่นที่ไม่เกี่ยว: แยก patch ออก เปิด worktree ใหม่ แล้วค่อย apply
- worktree พันกันจนแก้ยาก: เริ่มใหม่จาก main แล้วทำซ้ำแบบน้อยที่สุด

## Commit

- commit บ่อย แต่ละ commit ควรลงได้เอง และอ่านเรียงแล้วเป็นเหตุผล: test ที่ fail ก่อนการแก้, commit ลบก่อนการปรับรูป, baseline ก่อนการเปลี่ยน, scaffold ก่อนฟีเจอร์ วางลำดับนี้ตั้งแต่ตอน commit จะได้ไม่ต้องจัดใหม่ทีหลัง
- การแก้ทีหลังให้เป็น commit ใหม่ ถ้าเป็นของ commit ก่อนหน้าให้ใช้ `git commit --fixup=<sha>` แล้วก่อนส่งค่อยรวมด้วย `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <base>` (ไม่ต้องโต้ตอบ) จัดลำดับใหม่ทั้งชุดเมื่อจำเป็นด้วย `git reset --soft <base>` แล้ว commit ใหม่ทีละกลุ่มไฟล์ ห้ามเขียนประวัติใหม่บน branch ที่ push ไปแล้วโดยผู้ใช้ไม่ได้ขอ
- stage เฉพาะไฟล์ที่ตั้งใจ (`git add <files>`)
- body ของ commit ไม่ทวนหัวข้อ
- ก่อน commit อ่าน diff ทั้งหมดอีกรอบ: ลบโค้ดดีบัก, คอมเมนต์ที่เล่าขั้นตอน, ของ "เผื่อไว้" ที่ไม่มีหลักฐาน และ import ที่ไม่ใช้ (ดูเรื่องคอมเมนต์ใน `references/writing.md`)
- รัน lint และ typecheck ของ repo ก่อน push ห้ามข้าม hook คำเตือนที่มีอยู่ก่อนแล้วและไม่เกี่ยวกับงานนี้ ไม่ต้องแก้ (จะทำให้ diff บวม) ให้รายงานไว้บรรทัดเดียว repo ที่ไม่มี config lint ไม่ต้องเพิ่มเอง

## หัวข้อ

Conventional Commits `type(scope): หัวข้อ` ไม่มีจุดท้าย type เช่น `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf` scope คือส่วนของระบบ หัวข้อสั้น เป็นคำสั่ง และใส่ชื่อ symbol จริงถ้ามันคือแกนของการเปลี่ยน เช่น `fix(cart): stop double charge when retrying checkout` ภาษาของหัวข้อให้ตามธรรมเนียมของ repo
