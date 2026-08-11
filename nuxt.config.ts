import glsl from 'vite-plugin-glsl';
import tailwindcss from '@tailwindcss/vite';

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },

  modules: [
    '@nuxt/content',
    '@nuxt/eslint',
    '@nuxt/fonts',
    '@nuxt/hints',
    '@nuxt/icon',
    '@nuxt/image',
    'shadcn-nuxt',
  ],

  css: ['~/assets/css/tailwind.css'],
  vite: {
    plugins: [glsl(), tailwindcss()],
  },

  fonts: {
    families: [
      {
        name: 'Syne',
        preload: true,
        weights: ['400 800'],
      },
      {
        name: 'Instrument Sans',
        preload: true,
        weights: ['400 700'],
      },
    ],
  },
});
