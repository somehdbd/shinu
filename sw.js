// Cashbook service worker: makes the app installable and lets it open without internet.
// Your entries always come from Supabase; this file never stores them.
const VERSION = "cashbook-v2";
const SHELL = [
  "/",
  "/manifest.webmanifest",
  "/icon-192.png",
  "/icon-512.png",
  "/apple-touch-icon.png",
  "/favicon-64.png"
];
const LIB = "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.117.1/dist/umd/supabase.js";

self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(VERSION)
      // Save each file on its own, so one missing file never blocks the app from installing.
      .then(c => Promise.all([...SHELL, LIB].map(u => c.add(u).catch(() => {}))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", event => {
  const req = event.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);

  // Never cache Supabase (your data and sign-in).
  if (url.hostname.endsWith(".supabase.co") || url.hostname.endsWith(".supabase.in")) return;

  // The page itself: try the network first so updates show up, fall back to the saved copy offline.
  if (req.mode === "navigate") {
    event.respondWith(
      fetch(req)
        .then(res => { const copy = res.clone(); caches.open(VERSION).then(c => c.put("/", copy)); return res; })
        .catch(() => caches.match("/"))
    );
    return;
  }

  // Icons, the Supabase library and fonts: use the saved copy, fetch and save if missing.
  const cacheable = url.origin === self.location.origin ||
    url.hostname === "cdn.jsdelivr.net" ||
    url.hostname === "fonts.googleapis.com" ||
    url.hostname === "fonts.gstatic.com";
  if (!cacheable) return;
  event.respondWith(
    caches.match(req).then(hit => hit || fetch(req).then(res => {
      if (res.ok || res.type === "opaque") { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); }
      return res;
    }))
  );
});
