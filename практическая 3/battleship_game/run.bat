@echo off
echo 🚢 Запуск игры 'Морской бой'...
echo ==================================

REM Проверяем, установлен ли Dart
where dart >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Dart не найден. Пожалуйста, установите Dart SDK.
    echo 📥 Скачать можно с: https://dart.dev/get-dart
    pause
    exit /b 1
)

REM Проверяем, установлен ли Flutter
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter не найден. Пожалуйста, установите Flutter SDK.
    echo 📥 Скачать можно с: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Dart и Flutter найдены!
echo 🚀 Запускаем игру...
echo.

REM Устанавливаем зависимости
flutter pub get

REM Запускаем игру
dart run lib/main.dart

pause
