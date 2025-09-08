#!/bin/bash

# Скрипт для запуска демонстрации операторов Flutter/Dart

echo "=========================================="
echo "Демонстрация операторов Flutter/Dart"
echo "=========================================="
echo ""

# Проверяем наличие Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter не найден. Установите Flutter SDK."
    echo "Скачать можно с: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Проверяем наличие Dart
if ! command -v dart &> /dev/null; then
    echo "❌ Dart не найден. Установите Dart SDK."
    exit 1
fi

echo "✅ Flutter и Dart найдены"
echo ""

# Устанавливаем зависимости
echo "📦 Установка зависимостей..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Зависимости установлены успешно"
else
    echo "❌ Ошибка при установке зависимостей"
    exit 1
fi

echo ""
echo "🚀 Запуск программы..."
echo ""

# Запускаем программу
dart run lib/main.dart

