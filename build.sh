#!/bin/bash
mkdir -p build
echo "Компиляция парсера..."
dart compile exe bin/parser.dart -o build/gcloud_log_parser
echo "Компиляция подсветчика..."
dart compile exe bin/highlighter.dart -o build/gcloud_log_highlighter
echo "Готово!"
echo
echo "Исполняемые файлы:"
ls -la build/