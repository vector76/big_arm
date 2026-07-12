// Compile-time constants injected by vite.config.ts `define`.
// __BUILD_ID__ stamps each build; the twin appends it as ?v= to the
// fixed-URL CAD assets so a new deploy busts the browser + CDN caches.
declare const __BUILD_ID__: string;
