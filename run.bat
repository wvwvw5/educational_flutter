@echo off
chcp 65001 >nul

echo ==========================================
echo Демонстрация операторов Flutter/Dart
echo ==========================================
echo.

REM Проверяем наличие Flutter
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter не найден. Установите Flutter SDK.
    echo Скачать можно с: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Проверяем наличие Dart
dart --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Dart не найден. Установите Dart SDK.
    pause
    exit /b 1
)

echo ✅ Flutter и Dart найдены
echo.

REM Устанавливаем зависимости
echo 📦 Установка зависимостей...
flutter pub get

if %errorlevel% equ 0 (
    echo ✅ Зависимости установлены успешно
) else (
    echo ❌ Ошибка при установке зависимостей
    pause
    exit /b 1
)

echo.
echo 🚀 Запуск программы...
echo.

REM Запускаем программу
dart run lib/main.dart

pause

