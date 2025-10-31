### Подсветчик синтаксиса
```bash
# Просмотр output.txt из папки output (по умолчанию)
dart run bin/highlighter.dart

# Просмотр конкретного файла
dart run bin/highlighter.dart my_logs.txt

# Просмотр файла из другой директории
dart run bin/highlighter.dart ../other_project/output.txt

# После компиляции
./gcloud_log_highlighter
./gcloud_log_highlighter my_logs.txt