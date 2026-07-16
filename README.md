# C Chuvochkamu APK

Готовая база для сборки Flutter APK через GitHub Actions.

## Что менять

Основной код приложения лежит тут:

```text
lib/main.dart
```

Иконка приложения лежит тут:

```text
assets/avatar.png
```

Файл картинки должен называться именно `avatar.png`.

## Как собрать APK

1. Изменить `lib/main.dart`.
2. При желании заменить `assets/avatar.png`.
3. Нажать `Commit changes`.
4. Открыть вкладку `Actions`.
5. Дождаться зеленой галочки.
6. Открыть последний запуск.
7. Скачать artifact `pet-app-debug-apk`.
8. Внутри будет `app-debug.apk`.

## Старый файл

Оригинальный код сохранен в:

```text
Pipidastr.dart
```

Для сборки GitHub использует:

```text
lib/main.dart
```
