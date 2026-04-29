import path from 'path';
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, '.', '');
    return {
      server: {
        port: 3000,
        host: '0.0.0.0',
      },
      plugins: [
        react(),
        VitePWA({
          registerType: 'autoUpdate',
          includeAssets: ['favicon.ico', 'apple-touch-icon.png', 'masked-icon.svg'],
          manifest: {
            name: 'SmartGrow AI',
            short_name: 'SmartGrow',
            description: 'Professional plant care and disease diagnosis',
            theme_color: '#22c55e',
            background_color: '#f8fafc',
            display: 'standalone',
            orientation: 'portrait',
            scope: '/',
            start_url: '/',
            icons: [
              {
                src: '/icon-192x192.png',
                sizes: '192x192',
                type: 'image/png',
                purpose: 'any maskable'
              },
              {
                src: '/icon-512x512.png',
                sizes: '512x512',
                type: 'image/png',
                purpose: 'any maskable'
              }
            ]
          },
          workbox: {
            sourcemap: true,
            runtimeCaching: [
              {
                urlPattern: /^https:\/\/firebaseinstallations\.googleapis\.com\/.*/i,
                handler: 'NetworkFirst',
                options: {
                  cacheName: 'firebase-installations',
                  expiration: {
                    maxEntries: 10,
                    maxAgeSeconds: 60 * 60 * 24 * 7 // 7 days
                  }
                }
              }
            ]
          }
        })
      ],
      define: {
        'process.env.API_KEY': JSON.stringify(env.GEMINI_API_KEY),
        'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY)
      },
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '.'),
        }
      },
      build: {
        outDir: 'dist',
        sourcemap: mode !== 'production',
        minify: mode === 'production' ? 'esbuild' : false,
        rollupOptions: {
          output: {
            manualChunks: {
              react: ['react', 'react-dom'],
              firebase: ['firebase/app', 'firebase/auth', 'firebase/firestore', 'firebase/messaging'],
            },
          },
        },
      }
    };
  });
