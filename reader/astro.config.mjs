// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwindcss from '@tailwindcss/vite';
import AstroPwa from '@vite-pwa/astro';

// https://astro.build/config
export default defineConfig({
  integrations: [
    react(),
    AstroPwa({
      registerType: 'autoUpdate',
      injectRegister: 'script',
      manifest: {
        name: 'Project Codex Reader',
        short_name: 'Codex',
        description: 'A high-performance, SEO-optimized reader for Project Codex.',
        theme_color: '#ffffff',
        background_color: '#ffffff',
        display: 'standalone',
        icons: [
          {
            src: 'favicon.svg',
            sizes: 'any',
            type: 'image/svg+xml',
          },
          {
            src: 'favicon.ico',
            sizes: '32x32',
            type: 'image/x-icon',
          }
        ],
      },
      workbox: {
        globPatterns: ['**/*.{html,js,css,svg,png,ico,json}'],
        runtimeCaching: [
          {
            urlPattern: ({ url }) => url.pathname.endsWith('.json'),
            handler: 'NetworkFirst',
            options: {
              cacheName: 'codex-data-cache',
              expiration: {
                maxEntries: 10,
                maxAgeSeconds: 60 * 60 * 24 * 7, // 1 week
              },
              cacheableResponse: {
                statuses: [0, 200],
              },
            },
          },
        ],
      },
    }),
  ],

  vite: {
    plugins: [tailwindcss()]
  }
});
