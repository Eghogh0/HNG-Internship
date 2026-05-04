# WeatherNow – Cross‑Platform Weather App (HNG Stage 4)

A **single Flutter codebase** delivering a weather experience on  
📱 **Android & iOS** · 🖥️ **Windows, macOS, Linux** · 🌐 **Web (with offline PWA)**

## Features

- 🌤️ Current weather: temperature, humidity, wind, pressure, animated icon
- 📍 Auto‑location detection & manual city search
- 📅 5‑day forecast (representative midday data)
- 📴 Offline caching via `shared_preferences` (works on all platforms)
- 🎭 Smooth animations: staggered list entrance + page transitions (every platform)
- 🖥️ Desktop‑only: application menu bar (File/Edit/View/Help), keyboard shortcuts, right‑click context menus
- 🌐 Web‑only: PWA service worker for offline loading, clean URLs
- 📐 Responsive breakpoint at 600px – drawer on narrow, sidebar on wide

## Platform Adaptations

| Feature               | Mobile          | Desktop (Win/Mac/Linux) | Web                 |
|-----------------------|-----------------|-------------------------|---------------------|
| Navigation            | Drawer + AppBar | Sidebar NavigationRail + top menu bar | Same as desktop (wide) or drawer (narrow) |
| Input methods         | Touch, pull‑to‑refresh | Mouse hover, right‑click context menus, 5 keyboard shortcuts | All of the above |
| Offline support       | ✅              | ✅                      | ✅ (service worker) |
| Animations            | ✅              | ✅                      | ✅                  |
| Window resizing       | N/A             | ✅                      | ✅ (browser resize) |
| Keyboard shortcuts    | ❌              | Ctrl+R, F, H, Q, D      | Same shortcuts      |
| Context menus         | ❌              | Right‑click on weather card & forecast tiles | Right‑click |

## Keyboard Shortcuts (Desktop & Web)

| Shortcut   | Action                   |
|------------|--------------------------|
| Ctrl + R   | Refresh weather data     |
| Ctrl + F   | Search city              |
| Ctrl + H   | Go to home (refresh)     |
| Ctrl + Q   | Quit app (disabled on web) |
| Ctrl + D   | Open 5‑day forecast details |

## Folder Structure (shared vs platform‑specific)
