#!/bin/bash

echo "🎮 Запуск игры 'Крестики-нолики'..."
echo "=================================="

# Проверяем, установлен ли Dart
if ! command -v dart &> /dev/null; then
    echo "❌ Dart не найден. Пожалуйста, установите Dart SDK."
    echo "📥 Скачать можно с: https://dart.dev/get-dart"
    exit 1
fi

# Проверяем, установлен ли Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter не найден. Пожалуйста, установите Flutter SDK."
    echo "📥 Скачать можно с: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Dart и Flutter найдены!"
echo "🚀 Запускаем игру..."
echo ""

# Запускаем игру
dart run lib/main.dart
