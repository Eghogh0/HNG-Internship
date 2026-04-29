# Smart Utility Toolkit

A Flutter app that provides:
- **Unit Converter** (Length, Weight, Temperature, Currency)
- **Task Manager** (Create, edit, delete, mark completed – with offline storage)

## Features

### Unit Converter
- Convert between Meter, Kilometer, Centimeter
- Convert between Gram, Kilogram
- Convert Celsius ↔ Fahrenheit
- Convert NGN ↔ USD (static rates)

### Task Manager
- Add tasks with title + optional description
- Mark tasks as completed/uncompleted
- Edit any existing task
- Delete tasks with confirmation dialog
- All tasks are saved locally using SharedPreferences – works offline

## How to Run

1. Clone the repository
2. Ensure Flutter SDK is installed
3. Run `flutter pub get`
4. Run `flutter run`

## Build APK

```bash
flutter build apk --release