# TaxiGo — Flutter Taxi App

Приложение такси в стиле Яндекс.Такси / Uber на Flutter.

## Возможности

- Карта OpenStreetMap (без API-ключей Google Maps)
- Выбор точки отправления и назначения
- Тарифы: Эконом, Комфорт, Комфорт+, Бизнес
- Расчёт цены, расстояния и времени поездки
- Поиск водителя с анимацией на карте
- Отслеживание водителя до точки посадки и до пункта назначения
- Профиль и история поездок
- Жёлтая тема в стиле Яндекс.Такси

## Требования

- Flutter SDK 3.16+ ([установка](https://docs.flutter.dev/get-started/install))
- Android SDK (для сборки APK)
- JDK 17

## Быстрый старт

```bash
# Клонировать репозиторий
cd omad

# Установить зависимости
flutter pub get

# Запустить на эмуляторе/устройстве
flutter run
```

## Сборка APK

Сборка выполняется локально — CI/GitHub Actions не настроен.

### Debug APK

```bash
flutter build apk --debug
```

Файл: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```bash
flutter build apk --release
```

Файл: `build/app/outputs/flutter-apk/app-release.apk`

### Split APK по архитектурам (меньший размер)

```bash
flutter build apk --split-per-abi --release
```

## Структура проекта

```
lib/
├── main.dart              # Точка входа, splash-экран
├── models/                # Модели данных
├── providers/             # State management (Provider)
├── screens/               # Экраны приложения
├── services/              # Логика маршрутов, водителей, адресов
├── theme/                 # Цвета и тема
└── widgets/               # Переиспользуемые виджеты
```

## Разрешения Android

- `INTERNET` — загрузка тайлов карты
- `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` — определение местоположения

## Примечания

- Адреса и водители — демо-данные (Москва)
- Для продакшена подключите реальный геокодинг (Yandex/Google) и бэкенд
- Карта использует OpenStreetMap — нужен интернет на устройстве
