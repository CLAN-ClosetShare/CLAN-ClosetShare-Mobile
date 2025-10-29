# Hướng dẫn chạy CLOSET SHARE trên trình duyệt (Web)

## Yêu cầu

1. **Flutter SDK** - Cần cài đặt Flutter trên máy tính
2. **Chrome hoặc Edge** - Trình duyệt để chạy ứng dụng

## Cài đặt Flutter (nếu chưa có)

1. Tải Flutter SDK từ: https://docs.flutter.dev/get-started/install/windows
2. Giải nén vào thư mục (ví dụ: `C:\src\flutter`)
3. **Thêm Flutter vào PATH:**
   - Mở **System Properties** → **Environment Variables**
   - Thêm đường dẫn `C:\src\flutter\bin` vào **Path** (hoặc đường dẫn bạn đã giải nén)
   - Mở lại terminal/PowerShell để áp dụng thay đổi

4. Kiểm tra cài đặt:
   ```bash
   flutter doctor
   ```

## Chạy project trên Web

### Cách 1: Sử dụng script tự động (Khuyến nghị)

**Windows PowerShell:**
```powershell
.\run_web.ps1
```

**Windows CMD:**
```cmd
run_web.bat
```

**Lưu ý:** Script đã được cấu hình với đường dẫn Flutter: `C:\Users\LEGION\develop\flutter\bin`
- Nếu Flutter của bạn ở đường dẫn khác, chỉnh sửa biến `FLUTTER_PATH` trong file script

Script sẽ tự động:
- ✅ Tự động thêm Flutter vào PATH của session
- ✅ Kiểm tra Flutter
- ✅ Bật web support
- ✅ Cài đặt dependencies
- ✅ Chạy code generation
- ✅ Mở project trên trình duyệt

### Cách 2: Chạy thủ công

Nếu Flutter đã được thêm vào PATH, chạy các lệnh sau:

```bash
# 1. Bật web support (chỉ cần làm 1 lần)
flutter config --enable-web

# 2. Cài đặt dependencies
flutter pub get

# 3. Chạy code generation (nếu có sử dụng build_runner)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Chạy trên trình duyệt Chrome
flutter run -d chrome

# Hoặc chạy trên Edge
flutter run -d edge

# Hoặc chạy trên web server (mở http://localhost:8080)
flutter run -d web-server --web-port=8080
```

## Lưu ý

- Port mặc định: `8080` (có thể thay đổi bằng `--web-port`)
- Nhấn `Ctrl+C` trong terminal để dừng server
- Lần đầu chạy có thể mất vài phút để build
- Đảm bảo Chrome/Edge đã được cài đặt

## Xử lý lỗi

### Lỗi: "Flutter command not found"
- Đảm bảo Flutter đã được thêm vào PATH
- Mở lại terminal sau khi thêm vào PATH
- Hoặc chạy Flutter bằng đường dẫn đầy đủ: `C:\src\flutter\bin\flutter.bat`

### Lỗi: "Web support not enabled"
- Chạy: `flutter config --enable-web`
- Kiểm tra: `flutter devices` (sẽ thấy Chrome/Edge/Web)

### Lỗi khi cài đặt dependencies
- Kiểm tra kết nối internet
- Chạy: `flutter clean` và `flutter pub get` lại
- Kiểm tra file `pubspec.yaml` có đúng định dạng không

## Thông tin project

- **Tên**: CloseShare - Chia sẻ tủ đồ
- **Port web**: 8080
- **URL**: http://localhost:8080


