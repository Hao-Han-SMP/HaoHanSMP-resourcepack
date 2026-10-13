# Spec: Loại bỏ Note Block Override và khôi phục âm thanh Vanilla trong Resourcepack

## 1. Mục tiêu
- Loại bỏ hoàn toàn hệ thống custom block cũ dựa trên `note_block` trong resourcepack (`HaoHanSMP-resourcepack`).
- Khôi phục âm thanh `block.note_block.pling` về mặc định của vanilla Minecraft.
- Bảo tồn toàn bộ cấu hình mute Barrier cần thiết cho hệ thống CustomBlock mới của `HaoHanItemCore`.
- Giữ nguyên toàn bộ model khối (`assets/haohan/models/block/*.json`) vì các model item (`assets/haohan/models/item/*.json`) và Item Components 1.21.4 vẫn đang kế thừa (`parent`).

## 2. Phạm vi thay đổi (Chỉ phía Resourcepack)
1. **Xóa file:**
   - `assets/minecraft/blockstates/note_block.json` (3454 dòng, 115 KB)
2. **Sửa file:**
   - `assets/minecraft/sounds.json`:
     - Xóa object `block.note_block.pling`.
     - Giữ nguyên các entry `block.barrier.place`, `block.barrier.hit`, `block.barrier.step` và các custom disc/boss sounds.

## 3. Ràng buộc & Tiêu chí nghiệm thu
- Không xóa nhầm các file model `haohan:block/*.json`.
- `assets/minecraft/sounds.json` phải là JSON hợp lệ (valid syntax).
- Minecraft client khi tải resourcepack sẽ hiển thị và phát âm thanh note block nguyên bản của game gốc.
