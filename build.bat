@echo off

if not exist "build" mkdir build

if exist "build\windows" rmdir /s /q "build\windows"

mkdir "build\windows"

echo Компиляция парсера...
dart compile exe bin\parser.dart -o build\windows\parser.exe

echo Компиляция подсветчика...
dart compile exe bin\highlighter.dart -o build\windows\highlighter.exe

echo Копирование input.json...
if exist "example\input.json" (
    copy "example\input.json" "build\windows\"
    echo Файл input.json успешно скопирован
) else (
    echo ВНИМАНИЕ: Файл example\input.json не найден!
)

echo Готово!
echo.
echo Исполняемые файлы и данные:
dir build\windows\
