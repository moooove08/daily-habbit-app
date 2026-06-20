# Habbitator

Habbitator — iOS-приложение для формирования полезных привычек. Пользователь выбирает три привычки на день, отмечает их выполнение и наблюдает за прогрессом.

## Возможности

- создание трёх ежедневных привычек;
- замена или сохранение текущих привычек в начале нового дня;
- отметка выполненных задач;
- календарь с историей выполнения;
- статистика и серии успешных дней;
- несколько цветовых тем;
- локальное хранение данных через Core Data.

## Технологии

- Swift 5;
- UIKit;
- Core Data;
- Auto Layout;
- UserNotifications;
- iOS 14.0+;
- Clean Architecture + MVVM.

## Архитектура

Проект разделён на независимые слои:

```text
habbitator/
├── App/                     # Точка входа и сборка зависимостей
├── Core/                    # Общая конфигурация
├── Domain/                  # Модели и протоколы репозиториев
│   ├── Models/
│   └── Repositories/
├── Data/                    # Core Data, сервисы и реализации репозиториев
│   ├── Persistence/
│   ├── Repositories/
│   └── Services/
├── Presentation/            # UIKit-экраны и ViewModel
│   ├── Common/
│   ├── DesignSystem/
│   ├── Features/
│   └── Root/
└── Resources/               # Assets, LaunchScreen и Info.plist
```

Направление зависимостей:

```text
ViewController → ViewModel → HabitRepository
                                  ↑
                       CoreDataHabitRepository
                                  ↓
                             Core Data
```

Контроллеры не работают с Core Data напрямую. Они получают подготовленные данные от ViewModel, а ViewModel зависят от доменного протокола `HabitRepository`.

## Запуск

1. Откройте `habbitator.xcodeproj` в Xcode.
2. Выберите схему `habbitator`.
3. Выберите iPhone Simulator или подключённое устройство.
4. Запустите проект сочетанием `⌘R`.

Для сборки из терминала:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild \
  -project habbitator.xcodeproj \
  -scheme habbitator \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Хранение данных

Привычки и ежедневные отметки сохраняются локально в Core Data. При обновлении архитектуры формат существующего хранилища и пользовательская механика не изменялись.
