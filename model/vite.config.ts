import { resolve } from 'node:path';
import { defineConfig } from 'vite';

export default defineConfig({
  // Site is served from https://vector76.github.io/big_arm/
  base: '/big_arm/',
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        twin: resolve(__dirname, 'twin.html'),
      },
    },
  },
});
