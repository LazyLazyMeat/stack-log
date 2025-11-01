#!/bin/bash

mkdir -p build

if [ -d "build/linux" ]; then
    echo "Удаление старой папки linux..."
    rm -rf build/linux
fi

echo "Создание новой папки linux..."
mkdir -p build/linux

echo "Компиляция парсера..."
dart compile exe bin/parser.dart -o build/linux/stacklog_parser

echo "Компиляция подсветчика..."
dart compile exe bin/highlighter.dart -o build/linux/stacklog_highlighter

echo "Копирование input.json..."
if [ -f "example/input.json" ]; then
    cp example/input.json build/linux/
    echo "Файл input.json успешно скопирован"
else
    echo "ВНИМАНИЕ: Файл example/input.json не найден!"
fi

echo "Готово!"
echo
echo "Содержимое папки build/linux:"
ls -la build/linux/