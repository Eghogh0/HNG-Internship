# WeatherNow - HNG Internship Stage 3

**App chosen:** Weather Forecast App

## Features
- Real-time weather display (temperature, humidity, wind, conditions, icons)
- Current location detection with manual city search
- 5-day forecast (midday representative data)
- Offline caching with SharedPreferences (30-minute expiry)
- Smooth animations: staggered list entrances (Slide + Fade) and page transitions (PageTransition)
- Skeleton shimmer loading while fetching
- Comprehensive error handling (no internet, permission denied, API errors) with retry buttons

## APIs Used
- [OpenWeatherMap Current Weather](https://openweathermap.org/current)
- [OpenWeatherMap 5-Day Forecast](https://openweathermap.org/forecast5)

## Animation Highlights
- **List/Grid Items:** `flutter_staggered_animations` used for staggered slide + fade of weather cards and forecast tiles on home & forecast screens.
- **Screen Transitions:** `page_transition` provides right-to-left and bottom-to-top animations for search and forecast details screens.

## Dependencies & Architecture
- **State Management:** `setState` (lightweight, no external state management needed)
- **HTTP:** `http`
- **Location:** `geolocator`, `geocoding`
- **Caching:** `shared_preferences`
- **Loading:** `shimmer`
- **Animations:** `flutter_staggered_animations`, `page_transition`
- **Connectivity:** `connectivity_plus`

## Screenshots / Recordings
<img width="404" height="733" alt="image" src="https://github.com/user-attachments/assets/3bd5e247-1749-460d-bc88-ee9d2494aae5" />


## Setup & Run
1. Clone repo.
2. Insert your OpenWeatherMap API key in `lib/utils/constants.dart`.
3. Run `flutter pub get` and `flutter run`.
4. Build APK: `flutter build apk --release`.
