import { resolve } from 'node:path';
import { defineConfig } from 'vite';

export default defineConfig({
  // Site is served from https://vector76.github.io/big_arm/
  base: '/big_arm/',
  // Build id baked into the bundle to cache-bust the CAD assets
  // (cad/*.3mf + frames.json): they live at FIXED urls, and both the
  // browser and the GitHub Pages CDN cache them for max-age=600 — a
  // hard refresh doesn't reach through the CDN, so a fresh deploy can
  // serve new (hash-named, always-fresh) JS with stale meshes. The
  // bundle requests ?v=<id> instead: every deploy is a cold cache key.
  define: { __BUILD_ID__: JSON.stringify(Date.now().toString(36)) },
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        twin: resolve(__dirname, 'twin.html'),
      },
    },
  },
});
