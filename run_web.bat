@echo off
REM Script để cài đặt dependencies và chạy Flutter project trên web
REM Chạy script này bằng: run_web.bat

echo ========================================
echo   CLOSET SHARE - Flutter Web Setup
echo ========================================
echo.

REM Thiết lập đường dẫn Flutter
set FLUTTER_PATH=C:\Users\LEGION\develop\flutter\bin
set PATH=%FLUTTER_PATH%;%PATH%

REM Kiểm tra Flutter
echo Đang kiểm tra Flutter...
if not exist "%FLUTTER_PATH%\flutter.bat" (
    echo ❌ Không tìm thấy Flutter tại: %FLUTTER_PATH%
    echo.
    echo Vui lòng kiểm tra lại đường dẫn Flutter trong script!
    echo.
    pause
    exit /b 1
)

echo ✅ Flutter đã được tìm thấy tại: %FLUTTER_PATH%
echo.

REM Kiểm tra Flutter doctor
echo Đang kiểm tra Flutter doctor...
flutter doctor
echo.

REM Kiểm tra và bật web support
echo Đang kiểm tra Flutter web support...
flutter config --enable-web
echo ✅ Web support đã được bật!
echo.

REM Cài đặt dependencies
echo Đang cài đặt dependencies...
flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Có lỗi khi cài đặt dependencies!
    pause
    exit /b 1
)
echo ✅ Dependencies đã được cài đặt!
echo.

REM Chạy code generation (nếu cần)
echo Đang chạy code generation...
flutter pub run build_runner build --delete-conflicting-outputs
echo.

REM Chạy project trên web
echo ========================================
echo   Đang chạy project trên trình duyệt...
echo ========================================
echo.
echo Project sẽ được mở trên Chrome/Edge...
echo Nhấn Ctrl+C để dừng server
echo.

flutter run -d chrome --web-port=8080

pause


