self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open('weather-v1').then((cache) => {
      return cache.addAll([
        '/',
        '/index.html',
        '/main.dart.js',
        '/assets/AssetManifest.json',
        '/assets/FontManifest.json',
        '/assets/fonts/MaterialIcons-Regular.otf',
        // Add any other assets your app loads
      ]);
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => response || fetch(event.request))
  );
});