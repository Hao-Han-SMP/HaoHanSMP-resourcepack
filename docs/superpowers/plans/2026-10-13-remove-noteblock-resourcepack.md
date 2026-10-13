# Loại bỏ Note Block Override trong Resourcepack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Loại bỏ toàn bộ cấu hình ghi đè Note Block và khôi phục âm thanh pling gốc trong Resourcepack HaoHanSMP.

**Architecture:** Áp dụng nguyên tắc Ponytail (Deletion over Addition): xóa bỏ `note_block.json` blockstates thừa thãi và loại bỏ mục override mute sound trong `sounds.json`, bảo toàn các model texture và âm thanh barrier của hệ thống CustomBlock mới.

**Tech Stack:** Minecraft Resourcepack (JSON Assets, Blockstates, Sound Definitions).

**Spec:** `docs/superpowers/specs/2026-10-13-remove-noteblock-resourcepack-design.md`

## Global Constraints

- Chỉ chỉnh sửa trong phạm vi `HaoHanSMP-resourcepack`.
- Tuyệt đối không xóa hay làm hỏng các model khối `assets/haohan/models/block/*.json`.
- File `assets/minecraft/sounds.json` phải là định dạng JSON hợp lệ sau khi chỉnh sửa.
- Giữ nguyên các định nghĩa mute của barrier (`block.barrier.place`, `block.barrier.hit`, `block.barrier.step`).

## Review Focus

- Kiểm tra tính hợp lệ của file `sounds.json` bằng JSON parser (`python3 -m json.tool` hoặc `jq`).
- Xác nhận không còn bất kỳ file `note_block` nào trong thư mục `assets/minecraft/blockstates/`.
- Xác nhận các model item vẫn kế thừa trơn tru từ `assets/haohan/models/block/`.

---

### Task 1: Xóa bỏ Blockstates ghi đè Note Block

**Files:**
- Delete: `assets/minecraft/blockstates/note_block.json`

- [ ] **Step 1: Xóa file note_block.json**
Run: `rm -f assets/minecraft/blockstates/note_block.json`

- [ ] **Step 2: Kiểm tra xác nhận file đã bị xóa**
Run: `ls assets/minecraft/blockstates/`
Expected: Chỉ còn `jigsaw.json`, không còn `note_block.json`.

---

### Task 2: Khôi phục âm thanh Note Block Vanilla trong sounds.json

**Files:**
- Modify: `assets/minecraft/sounds.json`

- [ ] **Step 1: Xóa khối override block.note_block.pling khỏi sounds.json**
Xóa thuộc tính `block.note_block.pling` ở đầu file JSON.

- [ ] **Step 2: Kiểm tra cú pháp JSON hợp lệ**
Run: `python3 -m json.tool assets/minecraft/sounds.json > /dev/null`
Expected: Exit code 0, không có lỗi cú pháp syntax error.

- [ ] **Step 3: Kiểm tra nội dung sounds.json không còn note_block**
Run: `grep "note_block" assets/minecraft/sounds.json`
Expected: Không tìm thấy kết quả nào.

---

### Task 3: Xác minh toàn diện Resourcepack

**Files:**
- Test/Verify: `assets/`

- [ ] **Step 1: Kiểm tra các model block tùy chỉnh vẫn còn nguyên vẹn**
Run: `ls assets/haohan/models/block/anorthosite_ore.json assets/haohan/models/block/backpack.json assets/haohan/models/block/kreep_basalt.json`
Expected: Tất cả các file vẫn tồn tại.

- [ ] **Step 2: Kiểm tra git status**
Run: `git status -s`
Expected: Thấy deletion `assets/minecraft/blockstates/note_block.json` và modification `assets/minecraft/sounds.json`.
