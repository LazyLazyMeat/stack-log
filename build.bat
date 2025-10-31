@echo off
mkdir build 2>nul
echo Компиляция парсера...
dart compile exe bin/parser.dart -o build\gcloud_log_parser.exe
echo Компиляция подсветчика...
dart compile exe bin/highlighter.dart -o build\gcloud_log_highlighter.exe
echo Готово!
echo.
echo Исполняемые файлы:
dir build\*.exe