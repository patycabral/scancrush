export default defineNuxtConfig({
  devtools: { enabled: true },

  // Base do n8n fica SÓ no servidor (não vai pro bundle do cliente).
  // Em produção, defina NUXT_N8N_BASE no EasyPanel; sem isso, usa o fallback.
  runtimeConfig: {
    n8nBase: process.env.NUXT_N8N_BASE || 'https://scancrush-n8n.xpsbu9.easypanel.host',
  },

  modules: ['@nuxtjs/tailwindcss', '@nuxt/content'],

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
      script: [
        { src: 'https://www.googletagmanager.com/gtag/js?id=G-CFLFJK84RL', async: true },
        { innerHTML: `window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)}gtag('js',new Date());gtag('config','G-CFLFJK84RL');` },
      ],
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
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
    '/':           { ssr: true },
    '/lp':         { redirect: { to: '/', statusCode: 301 } },
    '/blog':       { ssr: true },
    '/blog/**':    { ssr: true },
    '/quiz':       { ssr: true },
    '/quiz/**':    { ssr: true },
    '/scan':       { ssr: false },
    '/tack':       { ssr: false },
    '/privacy':    { ssr: false },
    '/terms':      { ssr: false },
  },

  content: {
    highlight: false,
  },

  nitro: {
    compressPublicAssets: true,
    routeRules: {
      '/_nuxt/**': { headers: { 'cache-control': 'public, max-age=31536000, immutable' } },
      '/fonts/**': { headers: { 'cache-control': 'public, max-age=31536000, immutable' } },
    },
  },

  compatibilityDate: '2024-11-01',
})
