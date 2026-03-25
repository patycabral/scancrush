export default defineNuxtConfig({
  devtools: { enabled: true },

  modules: ['@nuxtjs/tailwindcss'],

  css: ['~/assets/css/main.css'],

  typescript: {
    strict: true,
  },

  app: {
    head: {
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1',
      title: 'ScanCrush — Análise emocional de conversas',
      meta: [
        { name: 'description', content: 'Descubra o que realmente está por trás das mensagens.' },
        { property: 'og:title', content: 'ScanCrush' },
        { property: 'og:description', content: 'Análise emocional de conversas com IA.' },
      ],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap',
        },
      ],
    },
  },

  // Tailwind config via @nuxtjs/tailwindcss
  tailwindcss: {
    configPath: '~/tailwind.config.ts',
  },

  // SSR apenas na landing page — o resto é client-only (sem indexação)
  routeRules: {
    '/':        { ssr: true },
    '/b':       { ssr: true },
    '/scan':    { ssr: false },
    '/tack':    { ssr: false },
    '/privacy': { ssr: false },
    '/terms':   { ssr: false },
  },

  compatibilityDate: '2024-11-01',
})
