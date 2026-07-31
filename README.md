# HaoHanSMP-resourcepack

Một resourcepack dành riêng cho server HaoHanSMP.

## Cách sử dụng

> **Lưu ý:** Resource pack này được thiết kế cho **Minecraft Java Edition** với pack format **94.1** (tức là phiên bản 1.21.1).

1. Tải file `HaoHanSMP-resourcepack.zip` từ phần [Releases](../../releases) hoặc tự build theo [hướng dẫn ở dưới](#build--package).
2. Mở Minecraft, vào **Options...** → **Resource Packs...**
3. Chọn **Open Pack Folder** để mở thư mục chứa resource pack.
4. Kéo file `.zip` vào thư mục vừa mở.
5. Chọn resource pack từ danh sách bên trái (Available) sang bên phải (Selected) và nhấn **Done**.

## Build / Package

Resource pack cung cấp sẵn script đóng gói cho cả Linux/macOS và Windows. File `.zip` đầu ra sẽ nằm trong thư mục `out/`.

### Windows (PowerShell)

```powershell
.\package.ps1
```

### Linux / macOS

```bash
chmod +x package.sh   # chỉ cần chạy lần đầu
./package.sh
```

> Yêu cầu: Lệnh `zip` phải được cài sẵn trên hệ thống.

## Giấy phép

Dự án được phát hành theo giấy phép [Creative Commons Attribution 4.0 International](LICENSE) (CC BY 4.0). 

Tóm tắt: Bạn được tự do sao chép, chia sẻ và chỉnh sửa tài nguyên cho bất kỳ mục đích nào (kể cả thương mại), miễn là ghi nhận bản quyền (ghi công) và dẫn liên kết đến giấy phép gốc phù hợp.

## Cảm ơn

(Bổ sung sau)