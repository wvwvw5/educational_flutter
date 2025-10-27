@echo off
chcp 65001 >nul

echo 🎮 Запуск игры 'Крестики-нолики'...
echo ==================================

REM Проверяем, установлен ли Dart
dart --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Dart не найден. Пожалуйста, установите Dart SDK.
    echo 📥 Скачать можно с: https://dart.dev/get-dart
    pause
    exit /b 1
)

REM Проверяем, установлен ли Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter не найден. Пожалуйста, установите Flutter SDK.
    echo 📥 Скачать можно с: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Dart и Flutter найдены!
echo 🚀 Запускаем игру...
echo.

REM Запускаем игру
dart run lib/main.dart

pause
