@echo off

if not exist "build" mkdir build

if exist "build\windows" rmdir /s /q "build\windows"

mkdir "build\windows"

echo Compiling parser...
dart compile exe bin\parser.dart -o build\windows\stacklog_parser.exe

echo Compiling highlighter...
dart compile exe bin\highlighter.dart -o build\windows\stacklog_highlighter.exe

echo Copying input.json...
if exist "example\input.json" (
    copy "example\input.json" "build\windows\"
    echo File input.json successfully copied
) else (
    echo WARNING: File example\input.json not found!
)

echo Creating cfg directory...
mkdir "build\windows\cfg"

echo Copying config.yaml...
if exist "example\config.yaml" (
    copy "example\config.yaml" "build\windows\cfg\"
    echo File config.yaml successfully copied to cfg\
) else (
    echo WARNING: File example\config.yaml not found!
)

echo Copying filters.txt...
if exist "example\filters.txt" (
    copy "example\filters.txt" "build\windows\cfg\"
    echo File filters.txt successfully copied to cfg\
) else (
    echo WARNING: File example\filters.txt not found!
)

echo Готово!
echo.
echo Executable files and data:
dir build\windows\
echo.
echo Configuration files:
dir build\windows\cfg\
