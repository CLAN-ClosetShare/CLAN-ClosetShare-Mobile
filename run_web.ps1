# Script để cài đặt dependencies và chạy Flutter project trên web
# Chạy script này bằng: .\run_web.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CLOSET SHARE - Flutter Web Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Thiết lập đường dẫn Flutter
$flutterPath = "C:\Users\LEGION\develop\flutter\bin"
$env:PATH = "$flutterPath;$env:PATH"

# Kiểm tra Flutter
Write-Host "Đang kiểm tra Flutter..." -ForegroundColor Yellow
if (-not (Test-Path "$flutterPath\flutter.bat")) {
    Write-Host "❌ Không tìm thấy Flutter tại: $flutterPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Vui lòng kiểm tra lại đường dẫn Flutter trong script!" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "✅ Flutter đã được tìm thấy tại: $flutterPath" -ForegroundColor Green
Write-Host ""

# Kiểm tra Flutter doctor
Write-Host "Đang kiểm tra Flutter doctor..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# Kiểm tra và bật web support
Write-Host "Đang kiểm tra Flutter web support..." -ForegroundColor Yellow
$devices = flutter devices 2>&1 | Out-String
if ($devices -notmatch "Chrome|Edge|Web") {
    Write-Host "⚠️  Flutter web chưa được bật. Đang bật web support..." -ForegroundColor Yellow
    flutter config --enable-web
    Write-Host "✅ Web support đã được bật!" -ForegroundColor Green
} else {
    Write-Host "✅ Flutter web đã được bật!" -ForegroundColor Green
}
Write-Host ""

# Cài đặt dependencies
Write-Host "Đang cài đặt dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Có lỗi khi cài đặt dependencies!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Dependencies đã được cài đặt!" -ForegroundColor Green
Write-Host ""

# Chạy code generation (nếu cần)
Write-Host "Đang chạy code generation..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs
Write-Host ""

# Chạy project trên web
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Đang chạy project trên trình duyệt..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Project sẽ được mở trên Chrome/Edge..." -ForegroundColor Yellow
Write-Host "Nhấn Ctrl+C để dừng server" -ForegroundColor Yellow
Write-Host ""

flutter run -d chrome --web-port=8080


