# Habbitator

Habbitator is an iOS app for building healthy habits. Users choose three habits for the day, mark them as completed, and track their progress.

## Features

- Create three daily habits;
- replace or keep the current habits at the start of a new day;
- mark tasks as completed;
- view completion history in a calendar;
- track statistics and successful-day streaks;
- choose from multiple color themes;
- store data locally with Core Data.

## Technologies

- Swift 5;
- UIKit;
- Core Data;
- Auto Layout;
- UserNotifications;
- iOS 14.0+;
- Clean Architecture + MVVM.

## Architecture

The project is divided into independent layers:

```text
habbitator/
├── App/                     # Entry point and dependency assembly
├── Core/                    # Shared configuration
├── Domain/                  # Models and repository protocols
│   ├── Models/
│   └── Repositories/
├── Data/                    # Core Data, services, and repository implementations
│   ├── Persistence/
│   ├── Repositories/
│   └── Services/
├── Presentation/            # UIKit screens and ViewModels
│   ├── Common/
│   ├── DesignSystem/
│   ├── Features/
│   └── Root/
└── Resources/               # Assets, LaunchScreen, and Info.plist
```

Dependency flow:

```text
ViewController → ViewModel → HabitRepository
                                  ↑
                       CoreDataHabitRepository
                                  ↓
                             Core Data
```

Controllers do not access Core Data directly. They receive prepared data from ViewModels, while the ViewModels depend on the domain-level `HabitRepository` protocol.

## Running the App

1. Open `habbitator.xcodeproj` in Xcode.
2. Select the `habbitator` scheme.
3. Choose an iPhone Simulator or a connected device.
4. Run the project with `⌘R`.

To build from the terminal:

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

## Data Storage

Habits and daily completion records are stored locally in Core Data. The architecture update did not change the existing persistent store format or user-facing behavior.
