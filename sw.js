// Basic Service Worker for PWA installability
const CACHE_NAME = 'tyk-cache-v1';

self.addEventListener('install', (event) => {
    self.skipWaiting();
});

self.addEventListener('activate', (event) => {
    event.waitUntil(clients.claim());
});

// A fetch listener is required for the PWA to be considered installable
self.addEventListener('fetch', (event) => {
    // We aren't doing offline caching yet, just passing requests through
    event.respondWith(fetch(event.request));
});
